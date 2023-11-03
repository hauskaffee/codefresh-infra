"use strict";
import * as pulumi from "@pulumi/pulumi";
import * as kubernetes from "@pulumi/kubernetes";

const config = new pulumi.Config();

const classicRE = new kubernetes.helm.v3.Release("cf-classic", {
    chart: config.require("chart-url"),
    version: config.get("chart-version"),
    name: "cf-classic-runtime",
    namespace: config.require("namespace"),
    createNamespace: true,
    waitForJobs: true,
    timeout: 600,
    values: {
        global: {
            codefreshToken: config.requireSecret("cf-api-token"),
            accountId: config.require("cf-account-id"),
            context: config.require("cluster-name"),
            agentName: config.require("cluster-name"),
        }
    },
});

export const helmVersion = classicRE.version;
export const status = classicRE.status;