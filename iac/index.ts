import * as fs from "fs";
import * as path from "path";
import testUsers from "./users.json";
import {all, Config, Input, jsonStringify, unsecret} from "@pulumi/pulumi";
import {UserPool, UserPoolClient, UserPoolDomain, UserGroup, User, UserInGroup} from "@pulumi/aws/cognito";
import {Instance} from "@pulumi/aws/rds";
import {Cluster, Service, TaskDefinition} from "@pulumi/aws/ecs";
import {Command} from "@pulumi/command/local";
import {propertiesFileToJson, resolvePlaceholders} from "./helper";

const config = new Config();

const trainingDb = new Instance("training-postgres", {
    identifier: "training-postgres",
    engine: "postgres",
    engineVersion: "16",
    instanceClass: "db.t3.micro",
    allocatedStorage: 20,
    dbName: config.require("dbName"),
    username: config.require("dbUsername"),
    password: config.require("dbPassword"),
    publiclyAccessible: true,
    skipFinalSnapshot: true,
});

type UserType = {
    "username": string,
    "email": string,
    "password": string,
    "memberOf": string[]
}

type UserGroupMap = Map<string, {name: string, group: UserGroup}>;

const userPool = new UserPool("myOidcUserPool", {
    name: "my-oidc-user-pool",
    passwordPolicy: {
        minimumLength: 8,
        requireLowercase: true,
        requireNumbers: true,
        requireUppercase: true,
        requireSymbols: false,
    },
});

new UserPoolDomain("myOidcDomain", {
    domain: "my-local-spring-app-auth",
    userPoolId: userPool.id,
});

// The app runs on the host (./gradlew bootRun) on 8080 and as an ECS task published on 8081.
// Both must be allowed to log in / log out via Cognito.
const localAppPort = 8080;
const ecsAppPort = 8081;
const appBaseUrls = [localAppPort, ecsAppPort].map(port => `http://localhost:${port}`);

const userPoolClient = new UserPoolClient("springBootClient", {
    userPoolId: userPool.id,
    generateSecret: true,
    explicitAuthFlows: ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"],
    allowedOauthFlows: ["code"],
    allowedOauthScopes: ["openid", "profile", "email"],
    callbackUrls: appBaseUrls.map(url => `${url}/login/oauth2/code/sso`),
    logoutUrls: appBaseUrls.map(url => `${url}/`),
    allowedOauthFlowsUserPoolClient: true,
});


const allUserGroups: UserGroupMap = new Map();
const createGroups = (user: UserType, userPool: UserPool): UserGroupMap => {
    const groups: UserGroupMap = new Map();
    for (const groupName of user.memberOf ?? []) {
        // register not existing group
        if (!allUserGroups.has(groupName)) {
            const group = new UserGroup(groupName, {
                name: groupName,
                userPoolId: userPool.id,
            });
            allUserGroups.set(groupName, {name: groupName, group});
        }
        groups.set(groupName, allUserGroups.get(groupName)!);
    }
    return groups;
}

const createGroupMembership = (
    user: UserType,
    cognitorUser: User,
    cognitoUserPool: UserPool,
) => {
    const userGroups: UserGroupMap = createGroups(user, userPool);
    for (const [name, cognitoGroup] of userGroups) {
        const uigName = `${user.username}-group-${name}-membership`;
        new UserInGroup(uigName, {
            userPoolId: cognitoUserPool.id,
            groupName: cognitoGroup.name,
            username: cognitorUser.username
        })
    }
}

const createUserAndGroups = (user: UserType, userPool: UserPool): void => {
    const cognitoUser = new User(`${user.username}`, {
        userPoolId: userPool.id,
        username: user.username,
        password: user.password,
        attributes: {
            email: user.email,
            email_verified: "true",
        },
        // Instructs Floci/Cognito to not try sending out a real activation email
        messageAction: "SUPPRESS",
    });
    createGroupMembership(user, cognitoUser, userPool);
}

testUsers.forEach((user: UserType) => {
    createUserAndGroups(user, userPool)
});

// ---------------------------------------------------------------------------------------------------
// ECS: runs the Spring Boot app as a real Docker container managed by Floci
// ---------------------------------------------------------------------------------------------------

// Image built locally by `./gradlew bootBuildImage` -> <group with dots replaced>/training-app:<version>,
// both read from ../gradle.properties (same rule as in build.gradle). A version bump therefore rolls out a new
// task definition on `pulumi up`. Floci runs locally built images without pushing them to a registry.
// Override with `pulumi config set appImage <image>`.
const gradleConf = propertiesFileToJson<{group: string, version: string}>("gradle.properties");
const appImage = config.get("appImage") ?? `${gradleConf.group}/training-app:${gradleConf.version}`;
// Hostname the task container uses to reach services published on the host
// (RDS on :7001, Floci on :4566, OTel collector on :4318). Works with Docker Desktop.
const hostAlias = config.get("hostAlias") ?? "host.docker.internal";
// Absolute host path of the project's keys/ folder (Docker Desktop shares /Users with its VM)
const keysDir = config.get("keysDir") ?? path.resolve(__dirname, "..", "keys");
// Port the app listens on inside the container
const containerPort = 8080;
const ecsAppUrl = `http://localhost:${ecsAppPort}`;
// Floci (behind floci-proxy) as seen by the browser vs. by the container
const flociBrowserUrl = "http://localhost:4566";
const flociContainerUrl = `http://${hostAlias}:4566`;

const appSettingsFile = path.join(__dirname, "floci-application-properties.json");
const appSettingsVars: Record<string, Input<string | number>> = {
    hostAlias,
    ecsAppUrl,
    flociBrowserUrl,
    flociContainerUrl,
    dbPort: trainingDb.port,
    dbName: trainingDb.dbName,
    dbUsername: trainingDb.username,
    dbPassword: config.requireSecret("dbPassword"),
    userPoolId: userPool.id,
    clientId: userPoolClient.id,
    clientSecret: userPoolClient.clientSecret,
};
const appSettings = all(appSettingsVars).apply(vars =>
    resolvePlaceholders(JSON.parse(fs.readFileSync(appSettingsFile, "utf8")), vars));

const appCluster = new Cluster("training-cluster", {
    name: "training-cluster",
});

const appTaskDefinition = new TaskDefinition("training-app", {
    family: "training-app",
    // bridge + EC2 avoids needing an emulated VPC/subnets (Fargate requires awsvpc)
    networkMode: "bridge",
    requiresCompatibilities: ["EC2"],
    cpu: "512",
    memory: "1024",
    // Signing keys for the embedded authorization server (app.security.signing-key.* = file:keys/...)
    // are not part of the image: mount the project's keys/ folder into the image's working dir.
    volumes: [{name: "signing-keys", hostPath: keysDir}],
    containerDefinitions: jsonStringify([{
        name: "training-app",
        image: appImage,
        essential: true,
        portMappings: [{containerPort: containerPort, hostPort: ecsAppPort, protocol: "tcp"}],
        // Paketo (bootBuildImage) images run from /workspace, so file:keys/... resolves to /workspace/keys
        mountPoints: [{sourceVolume: "signing-keys", containerPath: "/workspace/keys", readOnly: true}],
        environment: [
            {name: "SPRING_APPLICATION_JSON", value: jsonStringify(appSettings)},
        ],
    }]),
});

const appService = new Service("training-app", {
    name: "training-app",
    cluster: appCluster.arn,
    taskDefinition: appTaskDefinition.arn,
    launchType: "EC2",
    desiredCount: 1,
    // The task binds a fixed host port (8081), so old and new tasks cannot run side by side:
    // stop the old task first, then start the new one. Floci stores but ignores these, see stopStaleAppTasks.
    deploymentMinimumHealthyPercent: 0,
    deploymentMaximumPercent: 100,
});

// Floci's service reconciler starts tasks for the new task definition but never stops tasks of older revisions,
// so the old task keeps holding host port 8081 and the new one fails to start ("port is already allocated").
// After every task definition change, stop the service's tasks that are not on the current revision;
// Floci's next reconcile (~5s) then starts the new task. Needs the aws CLI on the host.
const awsConfig = new Config("aws");
const ecsEndpoint = (JSON.parse(awsConfig.get("endpoints") ?? "[{}]") as Record<string, string>[])[0]?.ecs;
new Command("stop-stale-app-tasks", {
    triggers: [appTaskDefinition.arn],
    environment: {
        AWS_ACCESS_KEY_ID: awsConfig.get("accessKey") ?? "test",
        AWS_SECRET_ACCESS_KEY: awsConfig.get("secretKey") ?? "test",
        AWS_REGION: awsConfig.get("region") ?? "us-east-1",
        ...(ecsEndpoint ? {AWS_ENDPOINT_URL: ecsEndpoint} : {}),
        CLUSTER: appCluster.name,
        SERVICE: appService.name,
        TASK_DEF: appTaskDefinition.arn,
    },
    create: `
set -eu
for task in $(aws ecs list-tasks --cluster "$CLUSTER" --service-name "$SERVICE" --desired-status RUNNING --query 'taskArns[]' --output text); do
  [ "$task" = "None" ] && continue
  taskDef=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$task" --query 'tasks[0].taskDefinitionArn' --output text)
  if [ "$taskDef" != "$TASK_DEF" ]; then
    echo "Stopping stale task $task ($taskDef)"
    aws ecs stop-task --cluster "$CLUSTER" --task "$task" --reason "Replaced by $TASK_DEF" --query 'task.lastStatus' --output text
  fi
done
`,
}, {dependsOn: [appService]});

export const ecsClusterName = appCluster.name;
export const ecsServiceName = appService.name;
// containerDefinitions is secret (it embeds dbPassword/clientSecret); only the image name is unwrapped
export const appImageName = unsecret(appTaskDefinition.containerDefinitions.apply(defs =>
    (JSON.parse(defs) as {name: string, image: string}[]).find(d => d.name === "training-app")?.image));
export const appUrl = ecsAppUrl;

export const userPoolId = userPool.id;
export const clientId = userPoolClient.id;
export const clientSecret = userPoolClient.clientSecret;

export const dbEndpoint = trainingDb.endpoint;
export const dbAddress = trainingDb.address;
export const dbPort = trainingDb.port;