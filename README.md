# Local Spark Cluster Repository

Have you ever wanted to run Spark scripts locally to quickly test if your code works before using a cloud platform?​

This local Spark cluster setup is designed specifically for that purpose – giving you the ability to run and test your Spark scripts right on your own machine.​

## Table of contents

1. [Purpose](#1-purpose)
2. [Repository Structure](#2-repository-structure)
3. [Prerequisites](#3-prerequisites)
4. [Cluster architecture](#4-cluster-architecture)
5. [How to use it ?](#5-how-to-use-it)
    - 5.1 [Launching the Spark Cluster](#1-launching-the-spark-cluster)
        - 5.1.1 [Navigate to the root directory of the repository](#1-navigate-to-the-root-directory-of-the-repository)
        - 5.1.2 [Start Docker containers](#2-start-docker-containers)
        - 5.1.3 [Check the status of the containers](#3-check-the-status-of-the-containers)
    - 5.2 [Creating PySpark Scripts](#2-creating-pyspark-scripts)
        - 5.2.1 [Importing the Spark Session](#1-importing-the-spark-session)
        - 5.2.2 [Using input Data](#2-using-input-data)
        - 5.2.3 [Writing your Spark logic](#3-writing-your-spark-logic)
        - 5.2.4 [Writing output data](#4-writing-output-data)
        - 5.2.5 [Script Template](#5-script-template)
    - 5.3 [Executing Python Scripts](#3-executing-python-scripts)
    - 5.4 [Stopping the Spark Cluster](#4-stopping-the-spark-cluster)
6. [Interfaces](#6-interfaces)
    - 6.1 [Accessing Jupyter Notebook](#1-accessing-jupyter-notebook)
    - 6.2 [Accessing Spark UI](#2-accessing-the-spark-ui)
    - 6.3 [Accessing Spark History Server](#3-accessing-spark-history-server)
7. [Conclusion](#7-conclusion)

## 1. Purpose:​

- **Test small Spark scripts quickly**: Run code to verify functionality

- **Local Spark environment**: Use when platforms like Databricks or AWS EMR are unavailable or unnecessary.

- **Training and learning**: Provides a simple setup for practicing and learning Spark.​​

## 2. Repository Structure

```bash
local-spark-cluster/
 ├── src/                 # Source code for Python scripts
 │ ├── init.py 
 │ ├── spark_session.py   # Script to initialize Spark session
 │ └── scripts/           # Directory for user scripts 
 │  ├── init.py 
 │  ├── script1.py        # Example Python script 1
 │  ├── script2.py        # Example Python script 2
 │  ├── notebook1.ipynb   # Example Notebook 1
 │  └── notebook2.ipynb   # Example Notebook 2
 ├── data/
 │  └── input/            # Input data storage 
 │  └── output/           # Output data storage 
 ├── .gitignore
 ├── docker-compose.yaml  # Docker configuration
 ├── README.md            # Project documentation
 └── spark_cluster.sh     # Bash script to manage spark cluster
```

## 3. Prerequisites

- **[Docker](https://docs.docker.com/get-docker/)** and **[Docker Compose](https://docs.docker.com/compose/install/)** installed on your machine.
- Basic understanding of **[Apache Spark](https://spark.apache.org/)** and **[Python](https://www.python.org/)**.

## 5. Cluster Architecture

The cluster provides a master-worker architecture used in distributed computing with Apache Spark:

- **Spark Master**: Central node responsible for managing resources and coordinating tasks across the cluster:

    - Spark scripts can be executed directly via the terminal. see [Executing Python Scripts](#3-executing-python-scripts)
    - Provides interfaces to monitor and manage the cluster. see [Accessing Spark UI](#2-accessing-the-spark-ui) and [Accessing Spark History Server](#3-accessing-spark-history-server)

- **Spark Worker(s)**: Perform the actual data processing:

    - The number of workers can be specified during deployment. see [Start Docker containers](#2-start-docker-containers)

- **Jupyter Notebook**: Offers an interactive environment to write and run Spark code in Python, connected directly to the Spark cluster. [Accessing Jupyter Notebook](#1-accessing-jupyter-notebook)


![architecture](https://github.com/user-attachments/assets/8f76e0cf-d370-4542-a4b9-c0acefc802d9)

## 5. How To Use It

The [spark_cluster.sh](./spark_cluster.sh) script provides following commands to manage the Spark cluster. 

- `deploy`: Starts the Spark cluster. 
    - `--no-jupyter` disable Jupyter notebook deployment
    - `--scale=<number>` set the number of worker. *Default to 1*
    - `--mem=<memory>` set the memory per worker. *Default to 1*
    - `--cores=<cores>` set the number of cores per worker. *Default to 1*

    *Example:*
    ```bash
    ./spark_cluster.sh deploy --no-jupyter --scale=2 --mem=3 --cores=2
    ```

- `status`: Displays the status of the Spark cluster.

    *Example:*
    ```bash
    ./spark_cluster.sh status
    ```

- `run <script>`: Executes a specified PySpark script.

    *Example:*
    ```bash
    ./spark_cluster.sh run script1.py
    ```

- `stop`: Stops all running containers in the Spark cluster.

    *Example:*
    ```bash
    ./spark_cluster.sh stop
    ```

### 1. Launching the Spark Cluster

#### 1. Navigate to the root directory of the repository:

```bash
cd path/to/your_local_repository
```

---

*⚠️ Make sure to replace `path/to/your_local_repository` with your local repository path*

#### 2. Start Docker containers:

You can start the Docker containers using the provided deployment scripts:

```bash
./spark_cluster.sh deploy
```

For more deployment options, see the [spark_cluster.sh usage section](#5-how-to-use-it).

#### 3. Check the status of the containers:

You can check containers status using the provided deployment scripts:

```bash
./spark_cluster.sh status
```

---

✅If everything is working correctly, you should see the list of your running containers, showing the name, state (e.g., Up), and ports for each service.

*For example:*

```bash
Name                              Command               State           Ports                  
-----------------------------------------------------------------------------------------------
spark-cluster-spark-master_1      /opt/bitnami/scripts/  Up              0.0.0.0:8080->8080/tcp
spark-cluster-spark-worker-1      /opt/bitnami/scripts/  Up                                    
```

This means that both the Spark master and worker nodes are running as expected and are accessible on their respective ports.

---

❌ If there are any issues, the `State` column might show `Exited` or `Restarting`, indicating that one or more containers have failed to start or are repeatedly restarting.

*For example:*

```bash
Name                              Command               State           Ports                  
-----------------------------------------------------------------------------------------------
spark-cluster-spark-master_1      /opt/bitnami/scripts/  Exited         0.0.0.0:8080->8080/tcp
spark-cluster-spark-worker-1      /opt/bitnami/scripts/  Up                                    
```

### 2. Creating PySpark Scripts

You can create and run your own PySpark scripts by placing them in the [./src/scripts/](./src/scripts/) folder.

To do so, follow the process outlined below.


#### 1. Importing the Spark Session:

To initialize a Spark session, import the `get_spark_session` function from the [spark_session.py](./src/spark_session.py) module:
- In the `get_spark_session` function, you need to provide a unique name for your Spark application.
- This name will identify the application in the Spark UI and will also be used to define the input and output paths. 

```python
from spark_session import get_spark_session

# Get the spark session and specify a name for your spark application
spark_session = get_spark_session("YourSparkApplicationName")
```

#### 2. Using input Data

Place your input files in [./data/input/](./data/input).

To read your DataFrame input, use the `read_dataframe` function defined in [spark_session.py](./src/spark_session.py) and which extends the Spark DataFrame functionality:
- This function read files from the [data/input](./data/input/) folder 
- This function automatically determines the file format based on the file extension.
- Additionally, you can pass various Spark read options through `**kwargs` to customize the reading process.

Supported input file formats:
- `csv`
- `parquet`
- `json`

Example:
```python
# Example usage of read_dataframe function
df = spark_session.read_dataframe(
    "data.csv",                           # Specify the input file with its path
    header=True,                          # Example of a Spark read option
    inferSchema=True,                     # Another Spark read option
)
```

#### 3. Writing your Spark logic

After initializing the Spark session, you can write your Spark logic as needed, such as reading data, performing transformations, analyzing datasets etc...

#### 4. Writing output data

To write your DataFrame output, use the `write_dataframe` function defined in [spark_session.py](./src/spark_session.py) and which extends the Spark DataFrame functionality:
- The output will be saved to [./data/output/](./data/output):


You can write the output in fthe following format:
- `csv`
- `parquet`
- `json`

 Exemple:
 ```python
 # Example usage of write_dataframe function
 df.write_dataframe(format="csv")
 ```

#### 5. Script Template

If you're unsure how to structure your script, templates are available at:
- python script: [./src/scripts/script_template.py](./src/scripts/script_template.py)
- jupyter notebook: [./src/scripts/notebook_template.ipynb](./src/scripts/notebook_template.ipynb)

These templates includes the basic setup for initializing a Spark session, reading input data, processing data and writing an output dataset.

### 3. Executing Python Scripts

You can run your spark scripts using the provided deployment scripts:

```bash
./spark_cluster.sh run <script1.py>
```

---

*⚠️ Make sure to replace `script1.py` with the name of your script.*

*Scripts are located in the `/home/spark/src/scripts/` directory within the container*

---


### 4. Stopping the Spark Cluster

When you are finished using the Spark cluster, you can stop all running containers.

You can stop the Spark Cluster using the provided deployment scripts:

```bash
./spark_cluster.sh stop
```

## 6. Interfaces

### 1. Accessing Jupyter Notebook

You can access Jupyter Notebook by navigating to: [http://localhost:8888](http://localhost:8888).

![jupyter-notebook](https://github.com/user-attachments/assets/9b8be047-b113-46e2-ad33-d1de83f49a11)

---

*By default, Jupyter will be enabled.*

*To disable Jupyter Notebook you should use the `--no-jupyter` flag when deploying the cluster. see [spark_cluster.sh usage section](#5-how-to-use-it)*

### 2. Accessing the Spark UI
You can access the Spark Master web UI to monitor your cluster and jobs by navigating to: [http://localhost:8080](http://localhost:8080).

![spark-ui](https://github.com/user-attachments/assets/27b249f9-269f-4c54-8ee9-81237018a9a1)

This UI provides an overview of the Spark cluster, including the status of jobs, executors, and other resources.

---

*For more details, refer to the official documentation: [Spark Monitoring and Instrumentation](https://spark.apache.org/docs/latest/monitoring.html)*

### 3. Accessing Spark History Server
To view the history of completed Spark applications, you can access the Spark History Server at: [http://localhost:18080](http://localhost:18080).

![spark-server-history](https://github.com/user-attachments/assets/0371b7ec-2845-44d5-a33b-6209877f5ab9)

This interface allows you to review the details of past Spark jobs, including execution times and resource usage.

---
*For more details, refer to the official documentation: [Spark History Server](https://spark.apache.org/docs/latest/monitoring.html#viewing-after-the-fact)*

## 7. Conclusion

This repository provides a Spark environment to run small PySpark scripts.

Feel free to add scripts in the [/src/scripts/](./src/scripts/) directory as needed for your data processing needs.

For any questions or issues, please refer to the following resources:
- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Docker Documentation](https://docs.docker.com/)
- [Bitnami Spark Docker Documentation](https://github.com/bitnami/bitnami-docker-spark)
- [PySpark Documentation](https://spark.apache.org/docs/latest/api/python/)

---

*For further assistance, feel free to contact me directly at [mathieu.masson@alten.com](mailto:mathieu.masson@alten.com).*

