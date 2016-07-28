/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.intel.flinkbench;

import java.util.ArrayList;

import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.java.functions.FunctionAnnotation.ForwardedFields;
import org.apache.flink.util.Collector;
import org.apache.flink.api.java.DataSet;
import org.apache.flink.api.java.ExecutionEnvironment;
import org.apache.flink.configuration.GlobalConfiguration;

@SuppressWarnings("serial")
public class JavaSleep {

    // *************************************************************************
    //     PROGRAM
    // *************************************************************************

    public static void main(String[] args) throws Exception {

        if (!parseParameters(args))
            return;

        // set up execution environment
        final ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();

        int parallelism =
            GlobalConfiguration.getInteger("parallelism.default", 0);
        System.out.println("Paral: " + parallelism);

        // get input data
        DataSet<Long> input =
            env.generateSequence(0, parallelism - 1);
        DataSet<Long> slept = input.map(new Sleeper());
        slept.count();
    }

    // *************************************************************************
    //     USER FUNCTIONS
    // *************************************************************************

    public static final class Sleeper implements MapFunction<Long, Long> {
        @Override
        public Long map(Long value) throws InterruptedException {
            Thread.sleep(seconds * 1000);
            return value;
        }
    }

    // *************************************************************************
    //     UTIL METHODS
    // *************************************************************************

    private static int seconds = 60;

    private static boolean parseParameters(String[] args) {

        if(args.length == 1) {
            seconds = Integer.parseInt(args[0]);
        } else {
            System.err.println("Usage: Sleep <seconds>");
            return false;
        }

        return true;
    }
}
