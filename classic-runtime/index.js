"use strict";
import * as pulumi from "@pulumi/pulumi";
import * as kubernetes from "@pulumi/kubernetes";

const config = new pulumi.Config();
const org = pulumi.getOrganization();
const stack = pulumi.getStack();
const stackRef = new pulumi.StackReference(`${org}/aws-infra/${stack}`);
const k8sCluster = stackRef.getOutput("clusterName").apply(cluster => cluster.toLowerCase());

const classicRE = new kubernetes.helm.v3.Release("cf-classic", {
    chart: config.require("chart-url"),
    name: "cf-classic-runtime",
    namespace: config.require("namespace"),
    createNamespace: true,
    waitForJobs: true,
    timeout: 600,
    values: {
        global: {
            codefreshToken: config.requireSecret("cf-api-token"),
            accountId: config.require("cf-account-id"),
            context: k8sCluster,
            agentName: k8sCluster,
        }
    },
});

export const helmVersion = classicRE.version;
export const status = classicRE.status;