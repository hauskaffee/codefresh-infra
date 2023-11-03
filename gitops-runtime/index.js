"use strict";
import * as pulumi from "@pulumi/pulumi";
import * as kubernetes from "@pulumi/kubernetes";
import { local } from "@pulumi/command";

const config = new pulumi.Config();

const gitopsRE = new kubernetes.helm.v3.Release("cf-gitops", {
    chart: config.require("chart-url"),
    namespace: config.require("namespace"),
    createNamespace: true,
    waitForJobs: true,
    timeout: 600,
    values: {
        global: {
            codefresh: {
                accountId: config.require("cf-account-id"),
                userToken: {
                    token: config.requireSecret("cf-api-token")
                }
            },
            runtime: {
                name: config.require("re-name"),
                gitCredentials: {
                    username: config.require("github-user"),
                    password: {
                        value: config.requireSecret("github-pat")
                    }
                }
            }
        }
    },
});

const gitopsPostIntall = new local.Command("cfPostInstall", {
    create: pulumi.interpolate`cf integration git register default --runtime ${config.require("re-name")} --token ${config.requireSecret("github-pat")}`
}, { dependsOn: [gitopsRE] });

export const helmVersion = gitopsRE.version;
export const appVersion = gitopsRE.appVersion;
export const status = gitopsRE.status;
export const gitopsPostInstall = gitopsPostIntall.stdout;