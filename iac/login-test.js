const baseUrl = "http://localhost:8080"
const tokenUrl = `${baseUrl}/oauth2/token`;
const clientId = "test";
const clientSecret = "test";

const requestBody = {
    grant_type: "client_credentials",
    scope: "api.read"
};
const headers = {
    "Content-Type": "application/x-www-form-urlencoded",
    "Authorization": `Basic ${Buffer.from(`${clientId}:${clientSecret}`).toString("base64")}`
}

try {
    const response = await fetch(tokenUrl, {
        method: "POST",
        headers,
        body: new URLSearchParams(requestBody)
    });
    if (!response.ok) {
        console.error("Token request failed", response.status)
        process.exit(1);
    }
    const token = await response.json();
    console.log("Token: ", token);

    const apiHeaders = {
        "Authorization": `Bearer ${token.access_token}`,
        "Content-Type": "application/json"
    };
    // use token
    const userInfoResponse = await fetch(
        `${baseUrl}/secured-endpoint/user-info`,
        {headers: apiHeaders}
    )

    if (userInfoResponse.ok) {
        console.log("API", userInfoResponse.status, await userInfoResponse.json());
    } else {
        console.log('Nope', userInfoResponse.status, userInfoResponse.error, await userInfoResponse.text());
    }


} catch (error) {
    console.error(error);
}