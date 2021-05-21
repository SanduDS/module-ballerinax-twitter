// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/log;
import ballerina/os;
import ballerina/regex;
import ballerina/test;
import ballerina/time;

string testClientId = os:getEnv("API_KEY");
string testClientSecret = os:getEnv("API_SECRET");
string testAccessToken = os:getEnv("ACCESS_TOKEN");
string testAccessTokenSecret = os:getEnv("ACCESS_TOKEN_SECRET");
int tweetId = 0;
int replytweetId = 0;
int user_id = 0;

TwitterConfiguration twitterConfig = {
    clientId: testClientId,
    clientSecret: testClientSecret,
    accessToken: testAccessToken,
    accessTokenSecret: testAccessTokenSecret
};

Client twitterClient = check new(twitterConfig);

@test:Config {}
function testTweet() {
    log:printInfo("testTweet");
    [int, decimal] & readonly currentTime = time:utcNow();
    string currentTimeStamp = currentTime[0].toString();
    string status = "Test tweet " + currentTimeStamp;
    var tweetResponse = twitterClient->tweet(status);

    if (tweetResponse is Status) {
        log:printInfo(tweetResponse.toString());
        tweetId = <@untainted> tweetResponse.id;
        test:assertTrue(regex:matches(tweetResponse.text, status), "Failed to call tweet()");
    } else {
        test:assertFail(tweetResponse.message());
    }
}

@test:Config {
    dependsOn: [testTweet]
}
function testReplyTweet() {
    log:printInfo("testReplyTweet");
    [int, decimal] & readonly currentTime = time:utcNow();
    string currentTimeStamp = currentTime[0].toString();
    string status = "Reply tweet " + currentTimeStamp;
    var tweetResponse = twitterClient->replyTweet(status, tweetId);

    if (tweetResponse is Status) {
        log:printInfo(tweetResponse.toString());
        replytweetId = <@untainted> tweetResponse.id;
        test:assertTrue(regex:matches(tweetResponse.text, status), "Failed to call replyTweet()");
    } else {
        test:assertFail(tweetResponse.message());
    }
}

@test:Config {
    dependsOn: [testReplyTweet]
}
function testReTweet() {
    log:printInfo("testReTweet");
    var tweetResponse = twitterClient->retweet(tweetId);

    if (tweetResponse is Status) {
        log:printInfo(tweetResponse.toString());
        test:assertTrue(tweetResponse.retweeted, "Failed to call retweet()");
    } else {
        test:assertFail(tweetResponse.message());
    }
}

@test:Config {
    dependsOn: [testReTweet]
}
function testDeleteReTweet() {
    log:printInfo("testDeleteReTweet");
    var tweetResponse = twitterClient->deleteRetweet(tweetId);

    if (tweetResponse is Status) {
        log:printInfo(tweetResponse.toString());
        test:assertEquals(tweetResponse.id, tweetId, "Failed to call deleteRetweet()");
    } else {
        test:assertFail(tweetResponse.message());
    }
}

@test:Config {}
function testSearch() {
    log:printInfo("testSearch");
    string queryStr = "SriLanka";
    SearchOptions request = {
        count: 10
    };
    var tweetResponse = twitterClient->search(queryStr, request);

    if (tweetResponse is error) {
        test:assertFail(tweetResponse.message());
    } else {
        log:printInfo(tweetResponse.toString());
        test:assertTrue(tweetResponse.length() > 0, "Failed to call search()");
    }
}

@test:Config {
    dependsOn: [testDeleteReTweet]
}
function testShowStatus() {
    log:printInfo("testShowStatus");
    var tweetResponse = twitterClient->showStatus(tweetId);

    if (tweetResponse is Status) {
        log:printInfo(tweetResponse.toString());
        test:assertEquals(tweetResponse.id, tweetId, "Failed to call showStatus()");
    } else {
        test:assertFail(tweetResponse.message());
    }
}

@test:Config {
    dependsOn: [testShowStatus]
}
function testDeleteTweet() {
    log:printInfo("testDeleteTweet");
    var tweetResponse = twitterClient->deleteTweet(tweetId);

    if (tweetResponse is Status) {
        log:printInfo(tweetResponse.toString());
        test:assertEquals(tweetResponse.id, tweetId, "Failed to call deleteTweet()");
    } else {
        test:assertFail(tweetResponse.message());
    }
}

@test:Config {
    dependsOn: [testTweet]
}
function testGetUserTimeline() {
    log:printInfo("testGetUserTimeline");
    var tweetResponse = twitterClient->getUserTimeline(5);

    if (tweetResponse is Status[]) {
        log:printInfo(tweetResponse.length().toString());
        test:assertTrue(true, "Failed to call getHomeTimeline()");
    } else {
        test:assertFail(tweetResponse.message());
    }
}

@test:Config {
    dependsOn: [testGetUserTimeline], enable: true
}
function testGetLast10Tweets() {
    log:printInfo("testGetLast10Tweets");
    var tweetResponse = twitterClient->getLast10Tweets(trimUser=true);

    if (tweetResponse is Status[]) {
        log:printInfo(tweetResponse.length().toString());
        test:assertTrue(true, "Failed to call getLast10Tweets()");
    } else {
        test:assertFail(tweetResponse.message());
    }
}

@test:Config {
    dependsOn: [testGetUserTimeline]
}
function testGetUser() {
    log:printInfo("testGetUser");
    var userResponse = twitterClient->getUser(user_id);

    if (userResponse is User) {
        log:printInfo(userResponse.toString());
        test:assertEquals(userResponse?.id, user_id.toString(), "Failed to call getUser()");
    } else {
        test:assertFail(userResponse.message());
    }
}

@test:Config {}
function testGetFollowers() {
    log:printInfo("testGetFollowers");
    var userResponse = twitterClient->getFollowers(user_id);

    if (userResponse is error) {
        test:assertFail(userResponse.message());
    } else {
        log:printInfo(userResponse.toString());
        test:assertTrue(userResponse.length() > 0, "Failed to call getFollowers()");
    }
}

@test:Config {}
function testGetFollowing() {
    log:printInfo("testGetFollowing");
    var userResponse = twitterClient->getFollowing(user_id);

    if (userResponse is error) {
        test:assertFail(userResponse.message());
    } else {
        log:printInfo(userResponse.toString());
        test:assertTrue(userResponse.length() > 0, "Failed to call getFollowing()");
    }
}

@test:AfterSuite { }
function afterSuite() {
    var tweetResponse = twitterClient->deleteTweet(replytweetId);
    if (tweetResponse is Status) {
        test:assertTrue(true, msg = "Delete Status Failed");
    } else {
        test:assertFail(msg = tweetResponse.message());
    }
}
