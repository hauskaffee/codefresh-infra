"use strict";
import * as pulumi from "@pulumi/pulumi";
import * as kubernetes from "@pulumi/kubernetes";
import { local } from "@pulumi/command";

const config = new pulumi.Config();
const org = pulumi.getOrganization();
const stack = pulumi.getStack();
const stackRef = new pulumi.StackReference(`${org}/aws-infra/${stack}`);
const k8sCluster = stackRef.getOutput("clusterName").apply(cluster => cluster.toLowerCase());


const gitopsRE = new kubernetes.helm.v3.Release("cf-gitops", {
    chart: config.require("chart-url"),
    name: "cf-gitops-runtime",
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
                name: k8sCluster,
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
    create: pulumi.interpolate`cf integration git register default --runtime ${k8sCluster} --token ${config.requireSecret("github-pat")}`
}, { dependsOn: [gitopsRE] });

export const helmVersion = gitopsRE.version;
export const status = gitopsRE.status;