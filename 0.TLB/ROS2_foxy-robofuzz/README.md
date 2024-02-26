
Related papers:

[HOUSE: Marco de trabajo modular de arquitectura escalable y desacoplada para el uso de técnicas de fuzzing en HPC](https://github.com/b0rh/Latex/blob/main/paper_JNIC_2021/HOUSE%20Marco%20de%20trabajo%20modular%20de%20arquitectura%20escalable%20y%20desacoplada%20para%20el%20uso%20de%20t%C3%A9cnicas%20de%20fuzzing%20en%20HPC.pdf) .

[Fuzzing Robotic Software using HPC](https://github.com/b0rh/Latex/blob/main/paper_CISIS_2023/Fuzzing%20Robotic%20Software%20using%20HPC.pdf) .


HOUSE framework guide - RoboFuzz
====================================

- [HOUSE framework guide - RoboFuzz](#house-framework-guide---robofuzz)
- [First steps](#first-steps)
  - [1. Get and prepare HOUSE source](#1-get-and-prepare-house-source)
  - [2. Build/Dowload ROS2-foxy + robofuzz singularity container](#2-builddowload-ros2-foxy--robofuzz-singularity-container)
    - [Download](#download)
    - [Build](#build)
  - [3. Get robofuzz source code](#3-get-robofuzz-source-code)
  - [4. Build/get Phoronix test suite directory fs](#4-buildget-phoronix-test-suite-directory-fs)
  - [5. Setup directories](#5-setup-directories)
  - [6.VNC configuration](#6vnc-configuration)
- [Directory mapping and layout (Host - Container)](#directory-mapping-and-layout-host---container)
  - [Results and context (host)](#results-and-context-host)
- [Robofuzz](#robofuzz)
  - [Supported experiments](#supported-experiments)
    - [Robofuzz example script list names](#robofuzz-example-script-list-names)
      - [Usage](#usage)
        - [Slurm + Singularity](#slurm--singularity)
        - [Singularity](#singularity)
- [Benchmark](#benchmark)
  - [Performance](#performance)
    - [Docker](#docker)
    - [Slurm + Singularity](#slurm--singularity-1)
    - [Singularity](#singularity-1)
  - [Fuzzing](#fuzzing)
    - [Docker](#docker-1)
      - [Benchmarking TurtleBot3 Burger](#benchmarking-turtlebot3-burger)
      - [Benchmarking Move It 2 + PANDA manipulator](#benchmarking-move-it-2--panda-manipulator)
    - [Slurm + Singularity](#slurm--singularity-2)
      - [Move It 2 + PANDA manipulator](#move-it-2--panda-manipulator)
      - [TurtleBot3 Burger](#turtlebot3-burger)
  - [Examples and scripts inline](#examples-and-scripts-inline)
    - [Parallel test](#parallel-test)
      - [High Performance Computing (HPC) - slurm + singularity](#high-performance-computing-hpc---slurm--singularity)
        - [2h x 5 + 5, 2h x 10 + 10, 2h x 20 + 20](#2h-x-5--5-2h-x-10--10-2h-x-20--20)
    - [Individual test](#individual-test)
      - [High Performance Computing (HPC) - slurm + singularity](#high-performance-computing-hpc---slurm--singularity-1)
        - [1h x 3 , 2h x 3 , 4h x 3](#1h-x-3--2h-x-3--4h-x-3)
      - [Standalone(SDO) - singularity](#standalonesdo---singularity)
        - [1h x 3, 2h x 3, 4h x 3](#1h-x-3-2h-x-3-4h-x-3)
      - [Standalone(SDO) - docker](#standalonesdo---docker)
        - [1h x 3, 2h x 3, 4h x 3](#1h-x-3-2h-x-3-4h-x-3-1)
  - [Fuzz benchmarking results handle](#fuzz-benchmarking-results-handle)
    - [Split by test](#split-by-test)
    - [Merge both test and clean data](#merge-both-test-and-clean-data)
    - [Generate score](#generate-score)
    - [Merge and grouping by environment-infrastructure-test and subtype](#merge-and-grouping-by-environment-infrastructure-test-and-subtype)
    - [Merge and grouping by environment-infrastructure, test and subtype](#merge-and-grouping-by-environment-infrastructure-test-and-subtype-1)
    - [Add score and grouping enviroment-infrastructure-subtype and test](#add-score-and-grouping-enviroment-infrastructure-subtype-and-test)
    - [Add score and grouping enviroment-infrastructure-test and subtype](#add-score-and-grouping-enviroment-infrastructure-test-and-subtype)
    - [Split by enviroment-infrastructure-test](#split-by-enviroment-infrastructure-test)
    - [Split by enviroment-infrastructure](#split-by-enviroment-infrastructure)
    - [Filter by singularity and single process (1hx3 or 2hx3 or 4hx3)](#filter-by-singularity-and-single-process-1hx3-or-2hx3-or-4hx3)
  - [Performance benchmarking results handle](#performance-benchmarking-results-handle)
- [Troubleshooting](#troubleshooting)
  - [Common failures](#common-failures)
    - [Script permission](#script-permission)
    - [Incomplete directory layout](#incomplete-directory-layout)


# First steps

## 1. Get and prepare HOUSE source

Dowload or clone repo release https://github.com/b0rh/HOUSE/releases as template.

`tar xfvz HOUSE-1-alfalfa.tar.gz -C ../SCRATCH/ `

Set name.

`cd ../SCRATCH/`

`mv HOUSE-1-alfalfa HOUSE`

Set *HS_ROOT* environment variable in configuration file `HOUSE/HS.conf` with the path to HOUSE directory in shared storage.

`#LUSTRE share storage scayle`

`HS_ROOT="/LUSTRE/SCRATCH/user_name_n/user_name_n_n/HOUSE"`

```bash
find HOUSE -name "*.sh" -exec chmod +x {} \;
```



## 2. Build/Dowload ROS2-foxy + robofuzz singularity container

### Download
[Download Singulary container Mirror 1](https://ss3.scayle.es:443/HOUSE/ROS2_foxy-robofuzz.sif)

[Download Singulary container Mirror 2](https://drive.google.com/file/d/1fg2InRNrwcbU3XKqwiTxA40YGrIYiRLD/view?usp=sharing)

`wget -O ROS2_foxy-robofuzz.sif  https://ss3.scayle.es:443/HOUSE/ROS2_foxy-robofuzz.sif`
or
`wget -O ROS2_foxy-robofuzz.sif  https://drive.google.com/file/d/1fg2InRNrwcbU3XKqwiTxA40YGrIYiRLD/view?usp=sharing`


### Build
```bash
cd BUILD
./0.singularity-build_container.sh ROS2_foxy-robofuzz.sif ROS2_foxy-robofuzz.def
```
## 3. Get robofuzz source code

```bash
cd ..
wget -O robofuzz_src_directory.tgz https://github.com/sslab-gatech/RoboFuzz/archive/refs/heads/master.zip
```
## 4. Build/get Phoronix test suite directory fs


```bash
./singularity-init.sh script ROS2_foxy-robofuzz.sif  ./BUILD/1.singularity-create_tgz_phoronix-test-suite_directory.sh
```
## 5. Setup directories

```bash
source clean-setup.sh
```
## 6.VNC configuration

Used in:
 - `./ROBOFUZZ/test_TurtleBot3_Burger.sh`
 - `./ROBOFUZZ/test_PX4_quadcopter_mutating_parameter.sh`

```bash

# Use VNC to use gui in HPC without complex configurations. export QT_QPA_PLATFORM=vnc:mode=websocket
# To use a web viewer in http://127.0.0.1:5900 if it's avaible for traditional vnc export QT_QPA_PLATFORM=vnc
# or disable with QT_QPA_PLATFORM=offscreen .Other options export QT_QPA_PLATFORM="vnc:size=1280x720:addr=0.0.0.0" .
# ref: https://github.com/pigshell/qtbase/blob/vnc-websocket/README.md

export DISPLAY=":30"
export QT_QPA_PLATFORM=vnc
```

More detailed in script comments.

# Directory mapping and layout (Host - Container)

Implemented in `singularity-init.sh`.

```bash
# BINDS
#          host(h_)          -      container (c_)
#   -------------------           -------------------
# ./robofuzz/{IDNUM}/src    <->      /robofuzz/src/      # Fuzzer cases and results output
# ./log/                    <->      /log/               # Stderr and Stdout container logs
# ./tmp/{IDNUM}/            <->      /tmp/               # Temporal files as lock and test case control
# ./                        <->      {c_OUTSIDE_PATH}    # Host basepath directory share inside container
# ./home/{IDNUM}/           <->      /home/              # Home directory
```

## Results and context (host)

**IDNUM** change for each container run with the EPOCH time in or JOBID in case of slurm job.

- **Variables defining in files:** /tmp/IDNUM/values/xxxx
- **Scipt and container execution logs:** /log/
- **ROS2 context:** /home/IDNUM/{container_user}/.ROS2
- **Simulator context:** /home/IDNUM/{container_user}/.gazebo
- **Performance benchmark:** /home/IDNUM/{container_user}/.phonronix
- **Fuzzer results:** /robofuzz/IDNUM/src/log

# Robofuzz
>RoboFuzz is a fuzzing framework for testing Robot Operating System 2 (ROS 2), and robotic systems that are built using ROS 2. Any developer-defined properties relating to the correctness of the robotic system under test, e.g., conformance to specification, can be tested using RoboFuzz.  
>
>- [Robofuzz website](https://github.com/sslab-gatech/RoboFuzz#robofuzz)

## Supported experiments
They are supported the same six targets that was introduce in [paper](https://squizz617.github.io/pubs/robofuzz-fse22.pdf), "RoboFuzz: Fuzzing Robotic Systems over Robot Operating System (ROS) for Finding Correctness Bugs", and part of robofuzz examples.
### Robofuzz example script list names

Scripts in **ROBOFUZZ** directory
```
run_PX4_quadcopter_micrortps_agent.sh
test_Move_It_2_plus_PANDA_manipulator.sh
test_PX4_quadcopter_mutating_parameter.sh
test_PX4_quadcopter_offboard_mode.sh
test_PX4_quadcopter_remote_control.sh
test_TurtleBot3_Burger.sh
test_Turtlesim.sh
```

- Two from the internal layers of ROS2 foxy:
    1. Type system (ROSIDL)
    2. ROS Client Library APIs (rclpy and rclcpp)

- Four ROS-based robotic systems/libraries:  
    3.  Turtlesim
    4.  Move It 2 + PANDA manipulator
    5.  TurtleBot3 Burger
    6.  PX4 quadcopter

#### Usage

##### Slurm + Singularity

Run benchmark inside a container in a host in HPC pool nodes managed by slurm.

Edit *exec-script-ROS2-robofuzz.slurm*  header to customize workload values such as node affinity, singularity version, etc. For more details <https://slurm.schedmd.com/sbatch.html#SECTION_INPUT-ENVIRONMENT-VARIABLES> .

```bash
sbatch exec-script-ROS2-robofuzz.slurm ./ROBOFUZZ/test_example_name.sh
```

##### Singularity

Run benchmark inside a container in the same host that script *singularity-init.sh*

```bash
./singularity-init.sh script ROS2_foxy-robofuzz.sif  ./ROBOFUZZ/test_example_name.sh
```


# Benchmark

## Performance

Perform all test in phronix test suites:

- **pts/sysbench:** General CPU and memory tests. [More details](https://openbenchmarking.org/test/pts/sysbench)
- **pts/byte:** Pure compute CPU tests. [More details](https://openbenchmarking.org/test/pts/byte)
- **pts/fs-mark:** Filesystem tests.  [More details](https://openbenchmarking.org/test/pts/fs-mark)

### Docker

**NOTE:** It's necessary attach to container  to complete batch-setup. Use  docker attach <Container_name>. Recommended configuration for full batch process YNnnnnY.

```bash
./BENCHMARK/docker-phoronix-text-suite.sh  > log/docker-phoronix-test-suite.sh-$(date +%s%3N).out
```

### Slurm + Singularity

Run benchmark inside a cotainer in a host in HPC pool nodes managed by slurm.

Edit *exec-script-ROS2-robofuzz.slurm*  header to customize workload values such as node afinity, singularity version, etc. For more details <https://slurm.schedmd.com/sbatch.html#SECTION_INPUT-ENVIRONMENT-VARIABLES> .

```bash
sbatch exec-script-ROS2-robofuzz.slurm ./BENCHMARK/singularity-phoronix-test-suite.sh
```

### Singularity

Run benchmark inside a container in the same host that script *singularity-init.sh*

```bash
./singularity-init.sh script ROS2_foxy-robofuzz.sif ./BENCHMARK/singularity-phoronix-test-suite.sh > log/singularity-phoronix-test-suite.sh-$(date +%s%3N).out
```

## Fuzzing

To set benchmarkin time set first script in the next way. Start SCRIPT, and kill it if still running after NUMBER seconds. SUFFIX may be 's' for seconds (the default), 'm' for minutes, 'h' for hours or 'd' for days.

**Examples:**
 **1 hour:** ./BENCHMARK/singularity-robofuzz_MI2.sh 1h
 **30 minutes:** ./BENCHMARK/docker-robofuzz_MI2.sh 30m

This define the first argument of timeout command that control de execution time for more details <https://linux.die.net/man/1/timeout> .

### Docker

#### Benchmarking TurtleBot3 Burger

```bash
./BENCHMARK/docker-robofuzz_TB3.sh 4h
```

#### Benchmarking Move It 2 + PANDA manipulator

```bash
./BENCHMARK/docker-robofuzz_MI2.sh 4h
```

### Slurm + Singularity

**NOTE:** Take care about time limit define in slurm file where the value of
`#SBATCH --time=0-72:00:00` is at least equals than the setted timeout.

#### Move It 2 + PANDA manipulator

```bash
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_MI2.sh 4h
```

#### TurtleBot3 Burger

```bash
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_TB3.sh 4h
```

## Examples and scripts inline

### Parallel test

#### High Performance Computing (HPC) - slurm + singularity

##### 2h x 5 + 5, 2h x 10 + 10, 2h x 20 + 20

Multiple 2 hours test in 3 groups. First group 10 paralell jobs, second one 20 paralell jobs, and third 40 paralell jobs. All jobs are half and half MI2 and TB3 Test.

```bash
for V in $(seq 1 5);do sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_MI2.sh 2h;sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_TB3.sh 2h;
done;\
mv log fuzz_2hx5+5_singularity@hpc;\
mkdir log;\
for V in $(seq 1 10);\
do sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_MI2.sh 2h;\
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_TB3.sh 2h;\
done;\
sleep 7230;\
mv log fuzz_2hx10+10_singularity@hpc;\
mkdir log;\
for V in $(seq 1 20);\
do sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_MI2.sh 2h;\
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_TB3.sh 2h;\
done;\
mv log fuzz_2hx20+20_singularity@hpc;\
mkdir log
```

### Individual test

Three blocks each with three iterations with two sequential MI2 and TB3 tests. First group 1 hour duration for each test, second group 2 hours and third group 4 hours.

#### High Performance Computing (HPC) - slurm + singularity

##### 1h x 3 , 2h x 3 , 4h x 3

```bash
for V in $(seq 1 3); do \
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_MI2.sh 1h;\
sleep 3630;\
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_TB3.sh 1h;\
sleep 3630;\
done;\
mv log fuzz_1hx3_singularity_hpc;\
mkdir log;\
for V in $(seq 1 3); do \
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_MI2.sh 2h;\
sleep 7230;\
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_TB3.sh 2h;\
sleep 7230;\
done;\
mv log fuzz_2hx3_singularity_hpc;\
mkdir log;\
for V in $(seq 1 3); do \
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_MI2.sh 4h;\
sleep 14430;\
sbatch exec-script-ROS2-robofuzz.slurm BENCHMARK/singularity-robofuzz_TB3.sh 4h;\
sleep 14430;\
done;\
mv log fuzz_4hx3_singularity_hpc;\
mkdir log
```

#### Standalone(SDO) - singularity

##### 1h x 3, 2h x 3, 4h x 3

NOTE: kill signal from host is used to avoid overlap resource between tests, default singularity configuration is permissive finishing child process. rm is used to keep enough free space in host due to bindings that save all  context for each one execution.

```bash
for V in $(seq 1 3); do \
./singularity-init.sh script ROS2_foxy-robofuzz.sif BENCHMARK/singularity-robofuzz_MI2.sh 1h;\
./singularity-init.sh script ROS2_foxy-robofuzz.sif BENCHMARK/singularity-robofuzz_TB3.sh 1h;\
kill -9 $(ps aux | grep -e "/robofuzz/ros2_foxy/" -e "/opt/ros/foxy/" -e "/phoronix-test-suite/" | awk -F " " '{print $2}');\
rm tmp home robofuzz -rf;\
done;\
mv log log_1hx3_singularity@sdo;\
mkdir log;\
for V in $(seq 1 3); do \
./singularity-init.sh script ROS2_foxy-robofuzz.sif BENCHMARK/singularity-robofuzz_MI2.sh 2h;\
./singularity-init.sh script ROS2_foxy-robofuzz.sif BENCHMARK/singularity-robofuzz_TB3.sh 2h;\
kill -9 $(ps aux | grep -e "/robofuzz/ros2_foxy/" -e "/opt/ros/foxy/" -e "/phoronix-test-suite/" | awk -F " " '{print $2}');\
rm tmp home robofuzz -rf;\
done;\
mv log fuzz_2hx3_singularity@sdo;\
mkdir log;\
for V in $(seq 1 3); do \
./singularity-init.sh script ROS2_foxy-robofuzz.sif BENCHMARK/singularity-robofuzz_MI2.sh 4h;\
./singularity-init.sh script ROS2_foxy-robofuzz.sif BENCHMARK/singularity-robofuzz_TB3.sh 4h;\
kill -9 $(ps aux | grep -e "/robofuzz/ros2_foxy/" -e "/opt/ros/foxy/" -e "/phoronix-test-suite/" | awk -F " " '{print $2}');\
rm tmp home robofuzz -rf;\
done;\
mv log fuzz_4hx3_singularity@sdo;\
mkdir log
```

#### Standalone(SDO) - docker

##### 1h x 3, 2h x 3, 4h x 3

```bash
for V in $(seq 1 3);\
do ./BENCHMARK/docker-robofuzz_TB3.sh 1h;\
./BENCHMARK/docker-robofuzz_MI2.sh 1h;\
done;\
mv log log_1hx3_docker@sdo;\
mkdir log;\
for V in $(seq 1 3);\
do ./BENCHMARK/docker-robofuzz_TB3.sh 2h;\
./BENCHMARK/docker-robofuzz_MI2.sh 2h;\
done;\
mv log log_2hx3_docker@sdo;\
mkdir log;\
for V in $(seq 1 3);\
do ./BENCHMARK/docker-robofuzz_TB3.sh 4h;\
./BENCHMARK/docker-robofuzz_MI2.sh 4h;\
done;\
mv log log_4hx3_docker@sdo;\
mkdir log
```


## Fuzz benchmarking results handle
To convert raw results to CSV is necessary to use the following directory name pattern.
`type_subtype_enviromment@infrastructure` 
Examples:
 - fuzz_1hx3_docker@sdo
 - benchmark_phoronix_singularity@hpc

[Experiment results](https://github.com/b0rh/HOUSE/tree/main/B.OR/TB3-MI2_Robofuzz) proccesed with the following scripts.


### Split by test
Set TEST to filter by script test MI2 or TB3. And type to filter by fuzz.

```bash
TEST=MI2;\
TYPE=fuzz;\
find $(ls | grep ${TYPE}) -name "*${TEST}*.*out" -exec sh -c "grep -H --label="$1" -n CYCLE -R {} | tail -n 1" \; | \
sed 's%\x1b\[[^\x1b]*m%%g' | \
sed 's%[_/: @]%;%g' | \
sed 's/;;/;/g' | \
cut -d ';' -f9,11,13,15 --complement \
> prueba_${TEST}.csv
```
### Merge both test and clean data
Put all together with headers and clean unnecessary data.

```bash
echo "type;subtype;environment;infrastructure;test;duration;cycle;round;exec" \
> Pruebas_MI2-TB3.csv;\
cat prueba_MI2.csv prueba_TB3.csv | \
cut -d ';' -f7,8 --complement | \
sed 's%singularity-robofuzz-%%g' | \
sed 's%docker-robofuzz-%%g' | \
sed 's%.sh%%g' \
>> Pruebas_MI2-TB3.csv
```
###  Generate score

Generate score and extract metric for each subtype test and set 0 metric without values.

```bash
for SUBTYPE in 1hx3 2hx3 4hx3;do \
for LINE in $(cat Pruebas_MI2-TB3.csv | sort | grep $SUBTYPE); do \
echo $LINE | awk -F ';' '{printf("%s,%s,%s,%s\n",$7,$8,$9,($7*5)+($8*10) + $9)}'; \
done | sed 's%,,%,0,%' \
> Metricas_score_$SUBTYPE.csv; \
done
```
### Merge and grouping by environment-infrastructure-test and subtype
Put all together grouping by environment-infrastructure-test and subtype as column value.

```bash
echo "environment-infrastructure-test,1hx3_cycle,1hx3_round,1hx3_exec,1hx3_score,2hx3_cycle,2hx3_round,2hx3_exec,2hx3_score,4hx3_cycle,4hx3_round,4hx3_exec,4hx3_score" > Pruebas_infra-env-test_subtype.csv ;\
cat Pruebas_MI2-TB3.csv | sort | grep fuzz | \
awk -F ';' '{getline S1 < "Metricas_score_1hx3.csv";getline S2 < "Metricas_score_2hx3.csv";getline S3 < "Metricas_score_4hx3.csv" ;printf "%s-%s-%s,%s,%s,%s\n",$3,$4,$5,S1,S2,S3}' \
 >> Pruebas_infra-env-test_subtype.csv

```
### Merge and grouping by environment-infrastructure, test and subtype
Put all together grouping by environment-infrastructure, test and subtype as column value.

```bash
echo "environment-infrastructure,test,1hx3_cycle,1hx3_round,1hx3_exec,1hx3_score,2hx3_cycle,2hx3_round,2hx3_exec,2hx3_score,4hx3_cycle,4hx3_round,4hx3_exec,4hx3_score" > Pruebas_infra-env_test.subtype.csv ;\
cat Pruebas_MI2-TB3.csv | sort | grep fuzz | \
awk -F ';' '{getline S1 < "Metricas_score_1hx3.csv";getline S2 < "Metricas_score_2hx3.csv";getline S3 < "Metricas_score_4hx3.csv" ;printf "%s-%s,%s,%s,%s,%s\n",$3,$4,$5,S1,S2,S3}' \
 >> Pruebas_infra-env_test.subtype.csv

```
### Add score and grouping enviroment-infrastructure-subtype and test
Grouping enviroment-infrastructure-subtype and test, add score.

```bash
echo "environment-infrastructure-subtype,test,duration,cycle,round,exec,score" > Pruebas_enviroment-infrastructure-subtype_test.csv;\
cat Pruebas_MI2-TB3.csv  | grep fuzz | sed 's%;;%;0;%'  | \
awk -F ';' '{printf("%s-%s-%s,%s,%s,%s,%s,%s,%s\n",$3,$4,$2,$5,$6,$7,$8,$9,($7*5)+($8*10) + $9)}' | sed 's%,,%,0,%'   \
>> Pruebas_enviroment-infrastructure-subtype_test.csv
```

### Add score and grouping enviroment-infrastructure-test and subtype 
Grouping enviroment-infrastructure-test and subtype and score as row value.

```bash
echo "environment-infrastructure-test,subtype,duration,cycle,round,exec,score" > Pruebas_enviroment-infrastructure-test+subtype.csv;\
cat Pruebas_MI2-TB3.csv  | grep fuzz | sed 's%;;%;0;%'  | \
awk -F ';' '{printf("%s-%s-%s,%s,%s,%s,%s,%s,%s\n",$3,$4,$5,$2,$6,$7,$8,$9,($7*5)+($8*10) + $9)}' | sed 's%,,%,0,%'   \
>> Pruebas_enviroment-infrastructure-test+subtype.csv
```

### Split by enviroment-infrastructure-test
```bash
for TYPE in $(cat Pruebas_enviroment-infrastructure-test+subtype.csv | awk -F ',' '{print $1}' | sort | uniq | grep -e hpc -e sdo); do echo "environment-infrastructure-test,subtype,duration,cycle,round,exec,score" > ./Pruebas_enviroment-infrastructure-test+subtype/Pruebas_${TYPE}_test+subtype.csv ;cat Pruebas_enviroment-infrastructure-test+subtype.csv | grep $TYPE >> ./Pruebas_enviroment-infrastructure-test+subtype/Pruebas_${TYPE}_test+subtype.csv;done
```

### Split by enviroment-infrastructure
**INFILE**: Input CSV File
**FILTERLIST**: Keywords to split
**OUTFILE**: Output CSV File
```bash
INFILE="Pruebas_enviroment-infrastructure-test+subtype.csv"; FILTERLIST="docker-sdo singularity-sdo singularity-hpc"; CSVHEADER="$(head -1 $INFILE)"; for TYPE in $FILTERLIST; do OUTFILE="./Pruebas_enviroment-infrastructure-test+subtype/Pruebas_${TYPE}-ALLTEST+subtype.csv"; echo $CSVHEADER > $OUTFILE; cat $INFILE | grep $TYPE >> $OUTFILE; done
```

### Filter by singularity and single process (1hx3 or 2hx3 or 4hx3)
**INFILE**: Input CSV File
**OUTFILE**: Output CSV File
```bash
TYPE="singularity_1hx3_2hx3_4hx3";INFILE="Pruebas_enviroment-infrastructure-test+subtype.csv";CSVHEADER="$(head -1 $INFILE)";OUTFILE="./Pruebas_enviroment-infrastructure-test+subtype/Pruebas_${TYPE}-ALLTEST+subtype.csv"; echo $CSVHEADER > $OUTFILE; cat $INFILE | grep singularity | grep -e 1hx3 -e 2hx3 -e 4hx3 >> $OUTFILE
```
## Performance benchmarking results handle

MPS: MiB per second
EPS: Events per second
FS: Files per second.


```bash
TYPE=benchmark;\
echo "type;subtype;environment;infrastructure;value;unit;category;testsuite;testNum" > Pruebas_phoronix.csv;\
find $(ls | grep ${TYPE}) -name "*.*out" -exec sh -c "grep -H --label="$1" -e 'Test: 4000 Files, 32 Sub Dirs, 1MB Size:' -e 'Computational Test: Dhrystone 2:' -e 'Test: RAM / Memory:' -e 'Test: CPU:' -A 13 -R {}" \; | \
grep 'Average:' | \
sed 's%\x1b\[[^\x1b]*m%%g' | \
sed 's%MiB/sec%MPS;memory;sysbench;1%g' | \
sed 's%Events Per Second%EPS;cpu;sysbench;2%g' | \
sed 's%LPS%LPS;compute;byte;1%g' | \
sed 's%Files/s%Fs;storage;fs-mark;3%g' | \
sed 's%[_/: @]%;%g' | \
sed 's/;;/;/g' | sed 's/;;/;/g' | \
sed 's/-;/;/g' | \
sed 's/\./,/g' | \
cut -d ';' -f5,6 --complement \
>> Pruebas_phoronix.csv
```

Prepares the columns by grouping and sorting 

```bash
TYPE=benchmark;\
echo "type-subtype-environment-infrastructure-category;value;unit;testsuite;testNum" > ./DATA_PAPER/benchmark_phoronix.csv;\
find $(ls | grep ${TYPE}) -name "*.*out" -exec sh -c "grep -H --label="$1" -e 'Test: 4000 Files, 32 Sub Dirs, 1MB Size:' -e 'Computational Test: Dhrystone 2:' -e 'Test: RAM / Memory:' -e 'Test: CPU:' -A 13 -R {}" \; | \
grep 'Average:' | \
sed 's%\x1b\[[^\x1b]*m%%g' | \
sed 's%MiB/sec%MPS;memory;sysbench;1%g' | \
sed 's%Events Per Second%EPS;cpu;sysbench;2%g' | \
sed 's%LPS%LPS;compute;byte;1%g' | \
sed 's%Files/s%Fs;storage;fs-mark;3%g' | \
sed 's%[_/: @]%;%g' | \
sed 's/;;/;/g' | sed 's/;;/;/g' | \
sed 's/-;/;/g' | \
cut -d ';' -f5,6 --complement | \
awk -F ';' '{printf("%s-%s-%s-%s-%s;%s;%s;%s;%s\n",$1,$2,$3,$4,$7,$5,$6,$8,$9,$10)}' \
>> ./benchmark_phoronix.csv
```

Change CSV to commas.

```bash
find ./DATA_PAPER/ -name "*.csv" -exec sed -i 's/,/\./g' {} \;
find ./DATA_PAPER/ -name "*.csv" -exec sed -i 's/;/,/g' {} \;
```
# Troubleshooting

## Common failures

### Script permission

**Symptom**
Nothing happens when send a job to slurm with sbatch or execute directly init script.

**Tipical errors**

```
./singularity-init.sh: Permission denied
```

```
./singularity-init.sh: Permission denied
srun: error: cn3014: task 0: Exited with exit code 13
srun: launch/slurm: _step_signal: Terminating StepId=1798692.0
```

**Solution**
In path where is the script or in base path execute:

```
find . -name "*.sh" -exec chmod +x {} \;
```

### Incomplete directory layout

**Symptom**
There are not logs or nothing happens when run some script or send a job to slurm. But execution permissions are fine.

**Typical errors**
There are no home, tmp, log and robofuzz directories.

```
find . -type d
.
./ROBOFUZZ
./BUILD
./TEMPLATE
./BENCHMARK
```

**Solution**
In  base path execute:
This remove all partial directories and create all new. NOTE: If you wan to save some results or context make first a copy data of directories home, tmp, log and robofuzz.

```
./clean-setup.sh
```

alternative solution, execute in base path:

```bash
mkdir -p tmp log robofuzz home
```
