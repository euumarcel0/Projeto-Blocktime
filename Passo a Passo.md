# 🔹 Projeto BlockTime

## **1. Acesse o Console AWS**
➡️ Clique no link para acessar o Console AWS:  
[🔗 Console AWS](https://aws.amazon.com)
Extraia a sua chave Key para rodar o terraform

---

## **2. Subir Terraform**
1. Baixe o projeto pelo GitHub: [Repositório](https://github.com/euumarcel0/Projeto-Blocktime.git) 

2. Abra o projeto pelo VScode.  

3. E Rode o Terraform para subir a infraestrutura.



---

## **3. Criação do CUR na AWS**
1. No painel de navegação da AWS à esquerda:
   - Digite **"Cost and Usage Reports"** na caixa de busca.  

2. Clique em **"Cost and Usage Reports"**.  

3. Clique no botão **"Create report"**.


4. Preencha os campos do relatório conforme abaixo:  
- **Report Name**: `MonthlyCostAndUsageReport`.  
- **Time Unit**: Escolha a granularidade do tempo:
  - `Hourly`, `Daily` ou `Monthly`. (Hourly)
- **Format**: Selecione `Parquet`.  
- **Compression**: Escolha `Parquet`.  
- **S3 Bucket**: Use o bucket `RelatorioS3`.  
- **Prefix**: Insira: `cur-reports/`.  
- **S3 Region**: `us-west-2`.  
- **Report Versioning**: Marque `Create new report`.  
- **Additional Schema Elements**: Inclua `RESOURCES`.

---

## **4. Gerar dados de custo dos meses anteriores**
1. No painel de navegação da AWS à esquerda:
   - Digite **"Cost Explorer"** na caixa de busca.  

2. Clique em **"Cost Explorer"**.  

3. Na página de serviços defina no calendário defina do 01/01 até 30/11 e clique em  **"Download as CSV"**.

4. **Crie a pasta no S3** chamada `total mes` no prefixo:  
   - `s3://relatorios3-blocktime/cur-reports/CUR/CUR/year=2024/`  
3. **Envie o arquivo manualmente** para o bucket com o prefixo:  
   - `s3://relatorios3-blocktime/cur-reports/CUR/CUR/year=2024/TotalMes/`

---

## **5. Criar Scripts na EC2**

### 1. Conecte-se na Instância EC2
Siga o processo usual para acessar a sua instância EC2 via SSH.

### 2. Execute os seguintes comandos:

1. **Atualizar pacotes e instalar dependências**
   Execute o seguinte comando para atualizar os pacotes e instalar os Necessários

   ```bash
   #Pacotes
   sudo apt update -y
   sudo apt upgrade -y
   sudo apt install python3 python3-pip -y
   sudo apt install python3-venv
   pip3 install boto3 --break-system-packages
   pip3 install pandas --break-system-packages
   pip3 install pymysql --break-system-packages
   pip3 install pyarrow --break-system-packages
   pip3 install s3fs --break-system-packages 
   sudo pip3 install mysql-connector-python --break-system-packages 
   sudo apt install nginx -y
   sudo apt-get install -y curl

   #Grafana
   sudo apt-get install -y apt-transport-https software-properties-common wget

   sudo mkdir -p /etc/apt/keyrings/
   wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

   echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

   echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

   sudo apt-get update
   sudo apt upgrade
   sudo apt-get install -y apt-transport-https software-properties-common wget
   sudo mkdir -p /etc/apt/keyrings/
   wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
   echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
   echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
   sudo apt-get install grafana -y 
   sudo apt-get install grafana
   sudo systemctl start grafana-server.service
   sudo systemctl enable grafana-server.service

   OU

   sudo apt install python3-venv
   python3 -m venv myenv
   source myenv/bin/activate
   pip3 install boto3 
   pip3 install pandas 
   pip3 install pymysql 
   pip3 install pyarrow 
   pip3 install s3fs  
   sudo pip3 install mysql-connector-python


   ```

### 3. **Configuração com a AWS**
    sudo mkdir -p /usr/share/grafana/.aws
    mkdir -p ~/.aws
    
    echo "[grafana]
    aws_access_key_id=AKIA4MJ4TNCYLN2IDEEV
    aws_secret_access_key=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" | sudo tee /usr/share/grafana/.aws/credentials > /dev/null

    echo "[default]
    aws_access_key_id=AKIA4MJ4TNCYLN2IDEEV
    aws_secret_access_key=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" | sudo tee ~/.aws/credentials

    #CloudWatch
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

    sudo apt install amazon-cloudwatch-agent

    sudo nano /opt/aws/amazon-cloudwatch-agent/bin/config.json

    Colar code: 
    {
    "metrics": {
        "metrics_collected": {
            "cpu": {
                "measurement": [
                "cpu_usage_idle",
                "cpu_usage_iowait",
                "cpu_usage_user",
                "cpu_usage_system",
                "cpu_usage_steal",
                "cpu_usage_guest",
                "cpu_usage_guest_nice"
                ],
                "metrics_collection_interval": 60
            },
            "mem": {
                "measurement": [
                "mem_used_percent",
                "mem_free",
                "mem_total",
                "mem_cached",
                "mem_available"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                "disk_used_percent",
                "disk_used",
                "disk_free"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                "*"
                ]
            },
            "network": {
                "measurement": [
                "network_in_bytes",
                "network_out_bytes",
                "network_in_packets",
                "network_out_packets",
                "network_drop_in",
                "network_drop_out",
                "network_error_in",
                "network_error_out"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                "swap_used_percent",
                "swap_used",
                "swap_free"
                ],
                "metrics_collection_interval": 60
            }
        },
        "append_dimensions": {
            "InstanceId": "${aws:InstanceId}",
            "AutoScalingGroupName": "${aws:AutoScalingGroupName}"
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                {
                    "file_path": "/var/log/messages",
                    "log_group_name": "/ec2/messages",
                    "log_stream_name": "{instance_id}"
                },
                {
                    "file_path": "/var/log/syslog",
                    "log_group_name": "/ec2/syslog",
                    "log_stream_name": "{instance_id}"
                },
                {
                    "file_path": "/var/log/cloud-init.log",
                    "log_group_name": "/ec2/cloud-init-log",
                    "log_stream_name": "{instance_id}"
                }
                ]
            }
        }
    }
    }

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status



### 4. Execute os seguintes comandos:

1. **Configuração de Automação de scripts**
  ```bash
  crontab -e

  adicionar:
  */10 * * * * /usr/bin/python3 /home/ec2-user/script/cur.py >> /home/ec2-user/cur.log 2>&1
  */10 * * * * /usr/bin/python3 /home/ec2-user/script/trail.py >> /home/ec2-user/trail.log 2>&1

  chmod +x /home/ec2-user/script/*.py
  ```


### 6. Criar Scipts:

1. **Criar os arquivos cur.py, trail.py e curtotal.py dentro da pasta scripts**

1.1 **curtotal.py**
  ```bash
  import pandas as pd
import mysql.connector
from mysql.connector import Error
import boto3
from io import StringIO

def conectar_banco():
    """Conecta ao banco de dados MySQL"""
    try:
        connection = mysql.connector.connect(
            host='bancodb.co7rhsq3nhrz.us-west-2.rds.amazonaws.com',
            database='billingdb',
            user='admin',
            password='blocktime134'
        )
        if connection.is_connected():
            print("Conectado ao banco de dados")
            return connection
    except Error as e:
        print(f"Erro ao conectar ao banco de dados: {e}")
        return None

def carregar_csv_do_s3(bucket, caminho_arquivo):
    """Carrega um arquivo CSV do S3"""
    try:
        s3_client = boto3.client('s3')
        response = s3_client.get_object(Bucket=bucket, Key=caminho_arquivo)
        csv_data = response['Body'].read().decode('utf-8')
        return pd.read_csv(StringIO(csv_data))
    except Exception as e:
        print(f"Erro ao carregar o arquivo do S3: {e}")
        return None

def inserir_dados(connection, data):
    """Insere os dados do DataFrame na tabela MySQL"""
    cursor = connection.cursor()
    sql = """
        INSERT INTO custos_servicos (
            servico, custo_banco_relacional, custo_instancias_ec2, custo_impostos, custo_ec2_outros,
            custo_vpc, custo_route53, custo_cloudwatch, custo_cloudtrail, custo_s3, custo_orcamentos,
            custo_ecr, custo_efs, custo_backup, custo_amplify, custo_lambda, custo_sns, custo_glue,
            custo_kms, custo_total
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    data = data.fillna(0)  # Substituir NaN por 0

    # Inserindo os dados
    for _, row in data.iterrows():
        values = tuple(row)
        try:
            cursor.execute(sql, values)
            connection.commit()
        except Error as e:
            print(f"Erro ao inserir dados: {e}")
            connection.rollback()
    print("Dados inseridos com sucesso")

def main():
    # Parâmetros do S3
    bucket_name = 'relatorios3-blocktime'
    s3_caminho = 'cur-reports/CUR/CUR/year=2024/TotalMes/costs.csv'

    # Carregando o CSV do S3
    data = carregar_csv_do_s3(bucket_name, s3_caminho)
    if data is None:
        print("Não foi possível carregar os dados do S3")
        return

    # Ajustando os nomes das colunas
    data.columns = [
        'servico', 'custo_banco_relacional', 'custo_instancias_ec2', 'custo_impostos', 'custo_ec2_outros',
        'custo_vpc', 'custo_route53', 'custo_cloudwatch', 'custo_cloudtrail', 'custo_s3', 'custo_orcamentos',
        'custo_ecr', 'custo_efs', 'custo_backup', 'custo_amplify', 'custo_lambda', 'custo_sns', 'custo_glue',
        'custo_kms', 'custo_total'
    ]

    # Conectando ao banco e inserindo os dados
    connection = conectar_banco()
    if connection:
        inserir_dados(connection, data)
        connection.close()

if __name__ == "__main__":
    main()

  ```
1.2 **cur.py**
  ```bash
import boto3
import pandas as pd
import pymysql
from botocore.exceptions import NoCredentialsError
import io

# Função para ler dados diretamente do S3 e retornar como DataFrame
def read_from_s3(bucket_name, prefix):
    s3 = boto3.client('s3', region_name='us-west-2')  # Especificando a região

    try:
        # Listando os objetos dentro do prefixo
        objects = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
        
        # Verificando a resposta de objetos
        print("Resposta do list_objects_v2:", objects)

        all_data = []

        if 'Contents' not in objects:
            print("Nenhum arquivo encontrado no S3.")
            return None
        
        print(f"Acessando o S3: {len(objects['Contents'])} arquivos encontrados.")
        
        for obj in objects['Contents']:
            file_key = obj['Key']
            print(f"Lendo arquivo: {file_key}")

            # Baixando o arquivo diretamente para memória
            s3_object = s3.get_object(Bucket=bucket_name, Key=file_key)
            file_content = s3_object['Body'].read()

            # Aqui, assume-se que o arquivo é Parquet
            try:
                df = pd.read_parquet(io.BytesIO(file_content))
                all_data.append(df)
            except Exception as e:
                print(f"Erro ao ler o arquivo Parquet {file_key}: {e}")
        
        # Concatenando todos os DataFrames, caso existam múltiplos arquivos
        if all_data:
            return pd.concat(all_data, ignore_index=True)
        else:
            print("Nenhum dado encontrado no arquivo.")
            return None
    except NoCredentialsError:
        print("Erro de credenciais: Certifique-se de que a AWS CLI está configurada corretamente.")
    except Exception as e:
        print(f"Erro ao acessar o S3: {e}")
    return None

# Função para conectar ao banco MySQL
def connect_to_mysql():
    try:
        connection = pymysql.connect(
            host='bancodb.co7rhsq3nhrz.us-west-2.rds.amazonaws.com',
            user='admin',
            password='blocktime134',
            db='billingdb',
            port=3306
        )
        print("Conectado ao banco de dados MySQL com sucesso.")
        return connection
    except Exception as e:
        print(f"Erro ao conectar ao MySQL: {e}")
        return None

# Função para inserir dados no MySQL
def insert_into_mysql(connection, df):
    cursor = connection.cursor()

    # Selecionando colunas que serão usadas na tabela do MySQL
    columns = [
        'line_item_usage_type', 'line_item_usage_amount', 'line_item_blended_cost',
        'identity_line_item_id', 'identity_time_interval', 'bill_invoicing_entity',
        'bill_billing_entity', 'bill_bill_type', 'bill_payer_account_id',
        'bill_billing_period_start_date', 'bill_billing_period_end_date',
        'line_item_usage_account_id', 'line_item_line_item_type', 'line_item_usage_start_date',
        'line_item_usage_end_date', 'line_item_currency_code', 'line_item_unblended_cost',
        'line_item_unblended_rate', 'line_item_unblended_usage_cost', 'product_product_name'
    ]

    # Limpeza: Remover valores nulos ou vazios na coluna product_product_name
    df['product_product_name'] = df['product_product_name'].fillna('').str.strip()

    # Filtrando apenas as colunas que existem no DataFrame
    available_columns = [col for col in columns if col in df.columns]
    sql = f"""
        INSERT INTO cur ({', '.join(available_columns)})
        VALUES ({', '.join(['%s'] * len(available_columns))})
    """

    # Inserindo os dados
    for _, row in df[available_columns].iterrows():
        try:
            cursor.execute(sql, tuple(row[col] for col in available_columns))
        except Exception as e:
            print(f"Erro ao inserir dados: {e}")

    connection.commit()
    cursor.close()
    print("Dados inseridos com sucesso no MySQL")

# Função para processar dados e inserir no banco MySQL
def process_data_and_insert_to_mysql(bucket_name, prefix):
    # Lendo os dados diretamente do S3
    df = read_from_s3(bucket_name, prefix)
    if df is not None:
        # Conectando ao banco de dados MySQL
        connection = connect_to_mysql()
        if connection:
            insert_into_mysql(connection, df)
            connection.close()

# Executando o processo completo
process_data_and_insert_to_mysql("relatorios3-blocktime", "cur-reports/CUR/CUR/")
 ```

1.2 **trail.py**
 ```bash
  import os
import boto3
import pandas as pd
import pymysql
import json
import gzip
from botocore.exceptions import NoCredentialsError
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone, timedelta

# Função para converter horário UTC para horário de Brasília
def convert_to_brasilia_time(utc_time_str):
    try:
        # Convertendo a string UTC para um objeto datetime
        utc_time = datetime.strptime(utc_time_str, "%Y-%m-%dT%H:%M:%SZ")
        
        # Definindo o fuso horário de Brasília (UTC-3)
        brasilia_tz = timezone(timedelta(hours=-3))
        
        # Convertendo para o horário de Brasília
        brasilia_time = utc_time.replace(tzinfo=timezone.utc).astimezone(brasilia_tz)
        
        # Retornando o horário no formato desejado
        return brasilia_time.strftime("%Y-%m-%d %H:%M:%S")
    except Exception as e:
        print(f"Erro ao converter horário: {utc_time_str} - {e}")
        return None

# Função principal para baixar e processar os arquivos do S3
def download_from_s3_and_process(bucket_name, prefix, connection):
    s3 = boto3.client('s3')

    try:
        # Usando o paginator para listar objetos em várias páginas
        paginator = s3.get_paginator('list_objects_v2')
        print(f"Conectado ao S3. Buscando arquivos no prefixo: {prefix}")

        # Usando um dicionário para armazenar a quantidade de arquivos por pasta
        folder_files_count = {}

        # Processando os objetos no S3 em paralelo com ThreadPoolExecutor
        def count_files_in_folder(folder):
            file_count = 0
            for sub_page in paginator.paginate(Bucket=bucket_name, Prefix=folder):
                if 'Contents' in sub_page:
                    file_count += len(sub_page['Contents'])
            folder_files_count[folder] = file_count

        for page in paginator.paginate(Bucket=bucket_name, Prefix=prefix, Delimiter='/'):
            if 'CommonPrefixes' in page:
                # Criando um pool de threads para contar arquivos em paralelo
                with ThreadPoolExecutor() as executor:
                    folders = [prefix_data['Prefix'] for prefix_data in page['CommonPrefixes']]
                    executor.map(count_files_in_folder, folders)

        # Exibindo no log a quantidade de arquivos encontrados em cada pasta
        for folder, count in folder_files_count.items():
            print(f"Encontrados {count} arquivos na pasta: {folder}")

        # Processando os arquivos encontrados nas pastas
        for folder in folder_files_count:
            process_files_in_folder(bucket_name, folder, connection)

    except NoCredentialsError:
        print("Erro de credenciais: Certifique-se de que a AWS CLI está configurada corretamente.")
    except Exception as e:
        print(f"Erro ao acessar o S3: {e}")

# Função para processar os arquivos em cada pasta
def process_files_in_folder(bucket_name, folder, connection):
    s3 = boto3.client('s3')

    # Listando os arquivos da pasta
    paginator = s3.get_paginator('list_objects_v2')

    # Lista para armazenar os dados processados
    data_list = []

    def process_file(file_key):
        try:
            # Baixando e descompactando o arquivo diretamente do S3
            response = s3.get_object(Bucket=bucket_name, Key=file_key)
            with gzip.GzipFile(fileobj=response['Body']) as f:
                data = json.load(f)
                for record in data.get('Records', []):
                    # Extraindo os campos de interesse e convertendo o horário para Brasília
                    event_time_brasilia = convert_to_brasilia_time(record.get('eventTime'))
                    record_data = {
                        'eventVersion': record.get('eventVersion'),
                        'userIdentity': record.get('userIdentity', {}).get('arn'),
                        'eventTime': event_time_brasilia,  # Horário convertido para Brasília
                        'eventSource': record.get('eventSource'),
                        'eventName': record.get('eventName'),
                        'awsRegion': record.get('awsRegion'),
                        'sourceIPAddress': record.get('sourceIPAddress'),
                        'userAgent': record.get('userAgent'),
                        'requestParameters': json.dumps(record.get('requestParameters', {})),
                        'responseElements': json.dumps(record.get('responseElements', {})),
                        'errorCode': record.get('errorCode'),
                        'errorMessage': record.get('errorMessage')
                    }
                    data_list.append(record_data)
        except Exception as e:
            print(f"Erro ao processar o arquivo {file_key}: {e}")

    for page in paginator.paginate(Bucket=bucket_name, Prefix=folder):
        if 'Contents' in page:
            # Usando ThreadPoolExecutor para baixar e processar arquivos em paralelo
            with ThreadPoolExecutor() as executor:
                file_keys = [obj['Key'] for obj in page['Contents'] if obj['Key'].endswith('.json.gz')]
                executor.map(process_file, file_keys)

    # Convertendo os dados para DataFrame
    if data_list:
        df = pd.DataFrame(data_list)

        # Exibindo as primeiras linhas do DataFrame
        print("Primeiras linhas do DataFrame filtrado:")
        print(df.head())

        # Inserindo no banco de dados MySQL
        insert_into_mysql(connection, df)
    else:
        print(f"Nenhum dado para processar na pasta: {folder}")

# Função para conectar ao banco MySQL
def connect_to_mysql():
    try:
        connection = pymysql.connect(
            host='bancodb.co7rhsq3nhrz.us-west-2.rds.amazonaws.com',
            user='admin',
            password='blocktime134',
            db='billingdb',
            port=3306
        )
        print("Conectado ao banco de dados MySQL com sucesso.")
        return connection
    except Exception as e:
        print(f"Erro ao conectar ao MySQL: {e}")
        return None

# Função para inserir dados no banco MySQL
def insert_into_mysql(connection, data):
    if not data.empty:
        cursor = connection.cursor()

        # Inserção em massa
        insert_query = """
            INSERT INTO cloudtrail_logs (
                eventVersion, userIdentity, eventTime, eventSource, eventName,
                awsRegion, sourceIPAddress, userAgent, requestParameters,
                responseElements, errorCode, errorMessage
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        # Usando executemany para inserção em massa
        cursor.executemany(insert_query, data.values.tolist())
        connection.commit()
        cursor.close()
        print("Dados inseridos no banco com sucesso.")
    else:
        print("Nenhum dado para inserir no banco.")

# Nome do bucket e prefixo no S3
bucket_name = 'relatorios3-blocktime'
prefix = 'AWSLogs/851067496624/CloudTrail/'

# Conectando ao banco de dados
connection = connect_to_mysql()

# Se a conexão foi bem-sucedida, começamos a processar os arquivos
if connection:
    download_from_s3_and_process(bucket_name, prefix, connection)
    connection.close()
 ```

### 7. Configuração do Banco de Dados:

1. **Criar as Tabela no Banco de Dados**

1.1 **CUR**
 ```bash
CREATE TABLE IF NOT EXISTS cur (
    identity_line_item_id VARCHAR(255),
    identity_time_interval VARCHAR(255),
    bill_invoicing_entity VARCHAR(255),
    bill_billing_entity VARCHAR(255),
    bill_bill_type VARCHAR(255),
    bill_payer_account_id VARCHAR(255),
    bill_billing_period_start_date DATETIME,
    bill_billing_period_end_date DATETIME,
    line_item_usage_account_id VARCHAR(255),
    line_item_line_item_type VARCHAR(255),
    line_item_usage_start_date DATETIME,
    line_item_usage_end_date DATETIME,
    line_item_product_code VARCHAR(255),
    line_item_usage_type VARCHAR(255),
    line_item_usage_amount DOUBLE,
    line_item_currency_code VARCHAR(255),
    pricing_currency VARCHAR(255) NOT NULL,
    pricing_public_on_demand_cost DOUBLE NOT NULL,
    line_item_unblended_rate VARCHAR(255),
    line_item_unblended_cost DOUBLE,
    line_item_blended_cost DOUBLE,
    product_product_name TEXT
);
 ```

1.2 **Trail**
 ```bash
 CREATE TABLE IF NOT EXISTS cloudtrail_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    eventVersion VARCHAR(255),
    userIdentity VARCHAR(255),
    eventTime DATETIME,
    eventSource VARCHAR(255),
    eventName VARCHAR(255),
    awsRegion VARCHAR(255),
    sourceIPAddress VARCHAR(255),
    userAgent VARCHAR(255),
    requestParameters TEXT,
    responseElements TEXT,
    errorCode VARCHAR(255),
    errorMessage VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    custo_total_geral DECIMAL(20, 4)
    
    ADD COLUMN eventID VARCHAR(255);

);
 ```
1.3 **CurTotal**
 ```bash
CREATE TABLE custos_servicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    servico VARCHAR(255) NOT NULL,
    custo_banco_relacional DECIMAL(10, 2),
    custo_instancias_ec2 DECIMAL(10, 2),
    custo_impostos DECIMAL(10, 2),
    custo_ec2_outros DECIMAL(10, 2),
    custo_vpc DECIMAL(10, 2),
    custo_route53 DECIMAL(10, 2),
    custo_cloudwatch DECIMAL(10, 2),
    custo_cloudtrail DECIMAL(10, 2),
    custo_s3 DECIMAL(10, 2),
    custo_orcamentos DECIMAL(10, 2),
    custo_ecr DECIMAL(10, 2),
    custo_efs DECIMAL(10, 2),
    custo_backup DECIMAL(10, 2),
    custo_amplify DECIMAL(10, 2),
    custo_lambda DECIMAL(10, 2),
    custo_sns DECIMAL(10, 2),
    custo_glue DECIMAL(10, 2),
    custo_kms DECIMAL(10, 2),
    custo_total DECIMAL(10, 2)
);
 ```


### 8. Configuração do Gráficos do Grafana:

1. Data Sources  
   
   ![Configuração do Grafana](DataSources.png)

2. Plugins  
   
   ![Configuração do Grafana](Plugins.png)



<div style="text-align: center;">
  <a target="_top" href="https://flamingtext.com/">
    <img src="https://blog.flamingtext.com/blog/2024/12/06/flamingtext_com_1733506156_313131829.png" 
         border="0" 
         alt="Logo Design by FlamingText.com" 
         title="Logo Design by FlamingText.com">
  </a>
</div>
