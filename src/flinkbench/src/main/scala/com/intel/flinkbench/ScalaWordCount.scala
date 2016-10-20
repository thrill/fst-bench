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

import org.apache.flink.api.scala._

/**
  * Implements the "WordCount" program that computes a simple word occurrence histogram
  * over text files.
  *
  * The input is a plain text file with lines separated by newline characters.
  *
  * Usage:
  * {{{
  *   WordCount <text path> <result path>>
  * }}}
  *
  * If no parameters are provided, the program is run with default data from
  * [[org.apache.flink.examples.java.wordcount.util.WordCountData]]
  *
  * This example shows how to:
  *
  *   - write a simple Flink program.
  *   - use Tuple data types.
  *   - write and use user-defined functions.
  *
  */
object ScalaWordCount {
  def main(args: Array[String]) {
    if (!parseParameters(args)) {
      return
    }

    val env = ExecutionEnvironment.getExecutionEnvironment
    val text = env.readTextFile(textPath)

    val counts = text.flatMap { _.split(" ") filter { _.nonEmpty } }
      .map { (_, 1) }
      .groupBy(0)
      .sum(1)

    counts.writeAsCsv(outputPath, "\n", " ")
    env.execute("Scala WordCount Example")
  }

  private def parseParameters(args: Array[String]): Boolean = {
    if (args.length == 2) {
      textPath = args(0)
      outputPath = args(1)
      true
    }
    else {
      System.err.println("Usage: WordCount <text path> <result path>")
      false
    }
  }

  private var textPath: String = null
  private var outputPath: String = null
}
