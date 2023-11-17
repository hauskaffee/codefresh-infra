"use strict";
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";
import * as eks from "@pulumi/eks";

const config = new pulumi.Config();
const minClusterSize = config.getNumber("minClusterSize") || 1;
const maxClusterSize = config.getNumber("maxClusterSize") || 6;
const desiredClusterSize = config.getNumber("desiredClusterSize") || 1;
const eksNodeInstanceType = config.get("eksNodeInstanceType") || "t3.medium";
const vpcNetworkCidr = config.get("vpcNetworkCidr") || "10.0.0.0/16";
const ownerTags = { "owner": config.require("ownerTag"), "pulumi": "true", "pulumi-stack": pulumi.getStack(), "pulumi-project": pulumi.getProject() }

const vpc01 = new awsx.ec2.Vpc(`${config.require("ownerTag")}-VPC`, {
    enableDnsHostnames: true,
    cidrBlock: vpcNetworkCidr,
    tags: ownerTags,
    subnetSpecs: [
        {
            type: awsx.ec2.SubnetType.Public,
            tags: ownerTags
        }
    ],
    natGateways: {
        strategy: "None"
    }
});

const eksNodeRole = new aws.iam.Role(`${config.require("ownerTag")}-k8s-eksRole-node`, {
    assumeRolePolicy: aws.iam.assumeRolePolicyForPrincipal({
        Service: "ec2.amazonaws.com",
    }),
    managedPolicyArns: ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",],
    tags: ownerTags
});

const k8s01 = new eks.Cluster(`${config.require("ownerTag")}-k8s`, {
    version: "1.28",
    vpcId: vpc01.vpcId,
    publicSubnetIds: vpc01.publicSubnetIds,
    useDefaultVpcCni: true,
    createOidcProvider: true,
    skipDefaultNodeGroup: true,
    instanceRoles: [eksNodeRole],
    tags: ownerTags,
});

const ng01 = new eks.ManagedNodeGroup(`${config.require("ownerTag")}-ng`, {
    cluster: k8s01,
    capacityType: "SPOT",
    instanceTypes: [eksNodeInstanceType],
    nodeRole: eksNodeRole,
    scalingConfig: {
        minSize: minClusterSize,
        desiredSize: desiredClusterSize,
        maxSize: maxClusterSize,
    },
    tags: ownerTags,
});


export const vpcId = vpc01.vpcId;
export const addCluster = pulumi.interpolate`aws eks update-kubeconfig --name ${k8s01.eksCluster.name}`;
export const removeCluster = pulumi.interpolate`kubectl config unset users.${k8s01.eksCluster.arn} && kubectl config unset contexts.${k8s01.eksCluster.arn} && kubectl config unset clusters.${k8s01.eksCluster.arn}`;
