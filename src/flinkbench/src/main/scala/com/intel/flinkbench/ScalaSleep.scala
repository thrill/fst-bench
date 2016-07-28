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
package com.intel.flinkbench

import java.lang.Iterable

import org.apache.flink.api.common.functions.GroupReduceFunction
import org.apache.flink.api.scala._
import org.apache.flink.api.java.aggregation.Aggregations.SUM
import org.apache.flink.configuration.GlobalConfiguration

import org.apache.flink.util.Collector

import scala.collection.JavaConverters._

object ScalaSleep {

  def main(args: Array[String]) {

    if (args.length != 1) {
      System.err.println(
        "Usage: Sleep <seconds>")
      return
    }

    val seconds = args(0).toLong
    val parallelism = GlobalConfiguration.getInteger("parallelism.default", 0)

    // set up execution environment
    val env = ExecutionEnvironment.getExecutionEnvironment

    // read input data
    val input = env.generateSequence(0, parallelism - 1)
    val slept = input.map(p => Thread.sleep(seconds * 1000L))
    slept.count()
  }
}
