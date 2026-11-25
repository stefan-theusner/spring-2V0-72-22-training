import fs from "node:fs";
import path from "node:path";
import {Cluster, TaskDefinition} from "@pulumi/aws/ecs";
import {all, Input} from "@pulumi/pulumi";

function readFileContents(file: string) {
    const targetPath = path.join(process.cwd(), '..', file);
    return fs.readFileSync(targetPath, "utf8");
}

function propertiesToJson<T>(prop: string) {
    const conf = prop.split(/\r?\n/)
        .filter(line => line && !line.startsWith("#") && line.includes("="))
        .map(line => line.trim())
        .map(keyVal => keyVal.split("="));
    return Object.fromEntries(conf) as T;
}

export function propertiesFileToJson<T>(filePath: string) {
    const propsContent = readFileContents(filePath);
    return propertiesToJson<T>(propsContent);
}

export function resolvePlaceholders (value: unknown, vars: Record<string, string | number>): unknown {
    if (typeof value === "string") {
        return value.replace(/\$\{(\w+)}/g, (placeholder, name: string) =>
            name in vars ? String(vars[name]) : placeholder);
    }
    if (Array.isArray(value)) {
        return value.map(item => resolvePlaceholders(item, vars));
    }
    if (value !== null && typeof value === "object") {
        return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, resolvePlaceholders(item, vars)]));
    }
    return value;
}
