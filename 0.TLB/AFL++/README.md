# Related paper 
- [HOUSE: Marco de trabajo modular de arquitectura escalable y desacoplada para el uso de técnicas de fuzzing en HPC](https://github.com/b0rh/Latex/blob/main/paper_JNIC_2021/HOUSE%20Marco%20de%20trabajo%20modular%20de%20arquitectura%20escalable%20y%20desacoplada%20para%20el%20uso%20de%20t%C3%A9cnicas%20de%20fuzzing%20en%20HPC.pdf) presentation [JNIC 2021](https://github.com/b0rh/Latex/blob/main/presentation_JNIC_2021/PresentacionJNIC2021.pdf) .

# HOUSE framework guide - AFL++ 
===============================

The following steps are an essential guide to deploy HOUSE framework on HPC cluster with slurm queuing system and use it.

- [HOUSE framework guide - AFL++](#house-framework-guide---afl)
    - [1.1. Prepare environment.](#11-prepare-environment)
    - [1.2. Build toolbox.](#12-build-toolbox)
      - [1.2.1. AFL++](#121-afl)
      - [1.2.2. **`WorkAround`** automake and aclocal](#122-workaround-automake-and-aclocal)
      - [1.2.3. **`WorkAround`** gperf *(optional)*](#123-workaround-gperf-optional)
    - [2.1. Prepare source code.](#21-prepare-source-code)
    - [2.2. Compile target source code or use previous compiled target.](#22-compile-target-source-code-or-use-previous-compiled-target)
    - [2.3. Workload package](#23-workload-package)
      - [2.3.1. Fuzzing workloads](#231-fuzzing-workloads)
        - [2.3.1.1. Configure target.](#2311-configure-target)
        - [2.3.1.2. Run Fuzzer.](#2312-run-fuzzer)
          - [2.3.1.2.1. Master fuzzer (MF) job](#23121-master-fuzzer-mf-job)
          - [2.3.1.2.2. Slave Fuzzer (SF) job](#23122-slave-fuzzer-sf-job)
        - [2.3.1.3. Fuzzing workload actions](#2313-fuzzing-workload-actions)
          - [2.3.1.3.1. Destroy](#23131-destroy)
          - [2.3.1.3.2. Clean](#23132-clean)
          - [2.3.1.3.3. Status](#23133-status)
      - [2.3.2. Self-checks workloads](#232-self-checks-workloads)
      - [2.3.3. Results analysis workloads *`(pending)`*](#233-results-analysis-workloads-pending)
      - [2.3.4. Input data generation workloads *`(pending)`*](#234-input-data-generation-workloads-pending)
    - [2.4. Check results.](#24-check-results)
      - [2.4.1. Error and outputs logs](#241-error-and-outputs-logs)
      - [2.4.2. Fuzzing jobs outputs](#242-fuzzing-jobs-outputs)
      - [2.4.3. Fuzzing jobs inputs](#243-fuzzing-jobs-inputs)



**Directory layout:**

  + **`0.TLB -` Tool box**: Tools, auxliar components and workarounds.
  + **`1.SCI -` Source Code Integrations**: Source code, patches, and integrations storage.
  + **`2.BRF -` Binaries ready to Fuzz**: Binaries storage.
  + **`3.WLP -` Workload packages** : Autonomous scalable jobs package.
  + **`A.IR - ` Inputs repository** : Seeds, dictionaries, example files,etc.
  + **`B.OR - ` Outputs repository**: Fuzzer context, results and useful output data.


**Common file structure:**

- **`clean.sh`**   Remove all logs, src and files to restore template default state.
- **`*action*-*description*.slurm`** Slurm script to execute as job(s).
- **`init.sh`** Main script to execute in compute nodes.



1. Deploy framework.
--------------------------

The unique requirements to use the framework are:

- Shared "SCRATCH" storage in all nodes.
- bash and slurm in all nodes.
- Tool box requirements. 

Only if you want to build or use your own toolbox, you need supplied each specific dependency in the nodes that you use for it.

>Due to performance and avoid compatibility issues is recommended to build the tools using the same environment.

### 1.1. Prepare environment.
Dowload or clone repo release https://github.com/b0rh/HOUSE/releases as template.

`tar xfvz HOUSE-1-alfalfa.tar.gz -C ../SCRATCH/ `

Set name.

`cd ../SCRATCH/`

`mv HOUSE-1-alfalfa HOUSE`

Set *HS_ROOT* environment variable in configuration file `HOUSE/HS.conf` with the path to HOUSE directory in shared storage.

`#LUSTRE share storage scayle`

`HS_ROOT="/LUSTRE/SCRATCH/user_name_n/user_name_n_n/HOUSE"`


`find HOUSE -name "*.sh" -exec chmod +x {} \;`


### 1.2. Build toolbox.
All available tools are stored in component **0.TLB** ready to compile.

#### 1.2.1. AFL++

To build AFL ++ execute slurm script *make-AFL++_haswell.slurm* in *HOUSE/0.TLB/AFL++/*.

`cd HOUSE/0.TLB/AFL++/`

`./clean.sh`

`sbatch make-AFL++.slurm`

#### 1.2.2. **`WorkAround`** automake and aclocal
Custom compilation to avoid limitations of the HPC environment such as the lack of a module with all dependencies. Necessary to work with coreutils and common Linux components.


`cd HOUSE/0.TLB/automake`

`./clean.sh`

`sbatch make-automake.slurm`

#### 1.2.3. **`WorkAround`** gperf *(optional)*
Binary extraction from official centos 7 rpm package to avoid limitations of the HPC environment such as the lack of a module with all dependencies. Necessary to compile coreutils.


`cd HOUSE/0.TLB/gperf`

`rpm2cpio gperf-3.0.4-8.el7.x86_64.rpm  | cpio -idmv`

`rm usr/share/ -rf`


2. Use framework
--------------------------
To illustrate how to use the framework in the following points will be detailed a complete example with coreutils as target.

### 2.1. Prepare source code. 

All auxiliar process, patches, integrations ... to compile target source code are in **1.SCI**.

***Example:***

To prepare coreutils source code.

`cd HOUSE/1.SCI/coreutils/`

`./clean.sh`

`sbatch prepare-coreutils_code.slurm`


### 2.2. Compile target source code or use previous compiled target.

The builds based on prepared code are in **2.BRF** *Binaries ready to fuzz* repository.

***Example:***

To compile the coreutils prepared code to add fuzzer instrumentation.

`cd HOUSE/2.BRF/coreutils/`

`./clean.sh`

`sbatch compile-coreutils.slurm`

### 2.3. Workload package
Any scalable or automatization workflow are define using package that including all necessary stuff to execute as autonomous job. The packages are storage individually in **3.WLP**.

#### 2.3.1. Fuzzing workloads

This kind of workload is used to scale fuzzing heavy processes or to paralyze long-term activities.

The workload packages naming it is combination of `target`.`class/family`.`profile`.

***Example:***

Coreutils has different workload packages depending on version or binaries to fuzz.

There are two coreutils examples one with the binary **date** at `HOUSE/3.WLP/date.coreutils.scayle`, and another with **expr** at `HOUSE/3.WLP/expr.coreutils.scayle`.

##### 2.3.1.1. Configure target.

An empty template for fuzzing binaries using AFL++ with instrumentation through stdin inputs is available at `HOUSE/3.WLP/_stdinparam.aflfuzzer.template_`.


Fuzzer workload adds the following files to common file structure:

- **`destroy.sh`** Cancel all jobs and remove all related outputs.
- **`status.sh`** Show details and stats about all fuzzer.
- **`target.conf`** Component configuration file.


***Example:***

Using as example the fuzzer workload package **date.coreutils.scayle**.

The `HOUSE/3.WLP/date.coreutils.scayle/target.conf` file contains:

+ Workload profile
  
  `_wlp="scayle"`

+ Binary target name
  
  `_target="date"`
  
+ Family/Class
  
  `_family="coreutils"`

+ Metric's tag
  
  `_step=fuzz-${_family}_${_target}`  

+ Binary *(BRF repository)*

    `_bin="${HS_ROOT}/2.BRF/${_family}/files/coreutils-8.32/usr/local/bin/${_target}"`

+ Test cases and seeds *(Inputs repository)*
  
    `_in="${HS_ROOT}/A.IR/${_family}/${_target}"`

+ Work environment *(Output repository)*
  `_out="${HS_ROOT}/B.OR/${_family}/${_target}.$_wlp/AFL"`

+ Initial param or case 0
  `_param=" --date='TZ=Europe/Madrid 09:00 next Fri'"`

##### 2.3.1.2. Run Fuzzer.
There are two types of fuzzers, master and slave. Master fuzzer there are only one and it is necessary to distribute works to slave fuzzers. The number of slaves fuzzer could be any, the limit it is the hardware capabilities.

>It is recommended use one job per fuzzer to have full support of **Fuzzing workload actions**.

###### 2.3.1.2.1. Master fuzzer (MF) job
To run the master fuzzer it is necessary first customize a slurm script, the template is available at `HOUSE/3.WLP/_stdinparam.aflfuzzer.template/run-master_fuzzer.slurm`. 

> To avoid unexpected behaviors it is mandatory have running only one master fuzzer during all fuzzing process.

***Example:***

Using as example the fuzzer workload package **date.coreutils.scayle**.

`cd HOUSE/3.WLP/date.coreutils.scayle`

Execute slurm script.
`sbatch run-master_fuzzer.slurm`

Check for MF in status output.
`./status.sh | grep MF`

###### 2.3.1.2.2. Slave Fuzzer (SF) job
To run a slave or any slaves fuzzer it is necessary first customize a slurm script, the template is available at `HOUSE/3.WLP/_stdinparam.aflfuzzer.template/run-slave_fuzzer.slurm`. 

> There are no limits, *only the available resources*, to execute multiple times `run-slave_fuzzer.slurm`, each execution adds a new running slave fuzzer to workload package.

***Example:***

Using as example the fuzzer workload package **date.coreutils.scayle**.

Execute slurm script to add one slave.

`cd HOUSE/3.WLP/date.coreutils.scayle`

`sbatch run-slave_fuzzer.slurm`

Check for SF in status output.

`./status.sh | grep SF`

To add 10 slaves with one command.

`for n in {1..10};do sbatch run-slave_fuzzer.slurm;done`


##### 2.3.1.3. Fuzzing workload actions
Some actions like destroy and status are specifics for fuzzing workloads.

###### 2.3.1.3.1. Destroy
To remove all data and to cancel all job related with the workload package.

***Example:***

To remove all data and cancel all related job related with workload package  **date.coreutils.scayle**.

`cd HOUSE/3.WLP/date.coreutils.scayle`

`./destroy.sh`

>Confirm with `y` to remove all workload package output data. This may cause loss of results or prevent to continue previous jobs.

###### 2.3.1.3.2. Clean
To restore initial workload package state. This means that all temporal or auxiliary stuff that was created will be remove such as logs, temporal files, etc.

> Combine with destroy to full reset context and state. It is useful for begin from full initial state at fuzzer workload level.

***Example:***

To restore initial workload package  **date.coreutils.scayle**.

`cd HOUSE/3.WLP/date.coreutils.scayle`

`./clean.sh`


###### 2.3.1.3.3. Status
Shows the following fuzzer details **for each one** related with the workload package:

+ **General fuzzer information**
  - **name**: SF for Slave Fuzzer and MF for Mater Fuzzer.
  - **state**: Current fuzzer state and total time running.
  - **node**: Node where the job is allocated.
  - **PID**: Fuzzer process identification.
  - **JOBID**: Fuzzer job identification.

+ **Fuzzer activity**
  - **last_path**: Time from finish last path.
  - **last_crash**: Time from finish last crash.
  - **last_hang**: Time from finish last hang.
  - **cycles_wo_finds**: Number of cycles without crashes.
  - **cycle**: Current cycle state such as speed, paths, coverage, crashes, etc.

+ **Performance metrics**
  - **AveCPU**: Average (system + user) CPU time of all tasks in job.
  - **AveDiskRead**: Average number of bytes read by all tasks in job.
  - **AveDiskWrite**: Average number of bytes written by all tasks in job.
  - **AveRSS**: Average resident set size of all tasks in job.
  - **AveVMSize**: Average Virtual Memory size of all tasks in job.
  - **MaxDiskRead**: Maximum number of bytes read by all tasks in job.
  - **MaxDiskWrite**: Maximum number of bytes written by all tasks in job.
  - **MaxRSS**: Maximum resident set size of all tasks in job.
  - **MaxVMSize**: Maximum Virtual Memory size of all tasks in job.

Status also performs a summary with accumulative data observer in all fuzzers used for workload package.

+ **Summary state**
  - **Fuzzer alive**: Number of fuzzers running. *(beta)*
  - **Total run time**: Global time running.
  - **Total execs**: Global executions.
  - **Cumulative speed**: Global number of executions per second.
  - **Average speed**: Global average number of executions per second.
  - **Pending paths**: *(beta)*
  - **Pending per fuzzer**: *(beta)*
  - **Crashes found**:  Global unique crash found.
  - **Cycles without finds**:  List of cycles without crashes.

***Example:***

To show individual and global status of all fuzzers related with the workload package  **date.coreutils.scayle**.

`cd HOUSE/3.WLP/date.coreutils.scayle`

`./status.sh`

#### 2.3.2. Self-checks workloads
This kind of workload is used to check performance or efficiency of different flows.

There are available a buffer overflow workload package **buffer_overflow.crashtest.scayle** with a testcase implemented to check the fuzzer operation.

To perform a test run with one master and one slave fuzzer, execute.

`cd HOUSE/3.WLP/buffer_overflow.crashtest.scayle`

`./clean.sh`

`sbatch run-master_fuzzer.slurm`

`sbatch run-slave_fuzzer.slurm`

#### 2.3.3. Results analysis workloads *`(pending)`*
This kind of workload is used to scale output data analysis.

#### 2.3.4. Input data generation workloads *`(pending)`*
This kind of workload is used to automatized test cases and seeds generation.

### 2.4. Check results.
#### 2.4.1. Error and outputs logs
The different slurm scripts storage the output and error logs in the same script path in directory <LogType>.

The naming is based on the following the template:

`/log/<ActivityType>-<family/class>.<JobID>_<TaskID>.<LogType>`.

+ **FuzzerType**: `MF` Master Fuzzer, `SF` Slave Fuzzer, compile, make, etc.
+ **family/class**: Common classification or Category.
+ **JobID**: Slurm job identification.
+ **TaskID**: Slurm task identification.
+ **LogType**: `err` for stderr and `out` for stdout.

***Example:***
To check activity logs related with the workload package  **date.coreutils.scayle**.

`cd HOUSE/3.WLP/date.coreutils.scayle`

To show master fuzzer error log.
`more log/MF-date.coreutils.930773_0.err `

To show master fuzzer output log.
`more log/MF-date.coreutils.930773_0.out `

#### 2.4.2. Fuzzing jobs outputs
The outputs are in a directory part of  **`B.OR - ` Outputs Repository**.It is defined in the file`target.conf` and field `_out` used to storage the fuzzer context, results and useful output data.

***Example:***
To list all outputs related with the workload package  **date.coreutils.scayle**.

`ls HOUSE/B.OR/coreutils/date.scayle`

#### 2.4.3. Fuzzing jobs inputs
The inputs are in a directory part of **`A.IR - ` Inputs Repository**. It is defined in the file `target.conf` and field `_in` used to storage the seeds, dictionaries, example files, etc.

***Example:***
To list all inputs related with the workload package  **date.coreutils.scayle**.

`ls HOUSE/A.IR/coreutils/date`
