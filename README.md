# Azure Data Factory project ( Price Catcher )

This is an ETL project to showcase the architecrue flow of Azure Data factory in processing Price Catcher dataset.
We will be using dataset provided from Malaysia's government database (KPDN & DOSM) under [license](https://creativecommons.org/licenses/by/4.0/). 

There are mainly 3 type of data. The first data is them item lookup, where each of the item is coded based on their category. The 2nd Lookup file is the premise lookup consists of coded premise and locations data such as states. The final dataset consists of 12 month data for 2023 of the price and conatincs 2 coded columns which refers to the previous lookup files.

Please refer the architecture flow below as we dive into the project where we will start with data ingestion

![Architecture](https://github.com/alifnrzm/Price-Catcher/blob/main/Pics/ArchitectFlow.jpg)

# Computing Power

For computing power, the serice tier selected for this project is the standard tier. This comes with a minimum of 10 database transaction unit (DTU) to calculate and bunvle the compute cost. Since this project does not require a large amount of data to be read and write, this is a viable option although there are higher tier available but it comes with the cost. While the data max size is 10 gb considering we have a full year of price data which can be large after processing. Hence the estimated cost for this comes down to 14.72USD which fall within the budget range. 

# Cost

The cost for running the resource group as a whole is at 33.75USD. For a personal project with limited amount of credit available, this is reasonable.

# Data Ingestion 
The datasets are ingested using two ways, using a http connector to ingest the lookup datas and blob storage from local storage. It is then stored into Azure Data Lake Gen2 (ADLS) through copy activity. 

**Lookup List (HTTP Connector)**
  
![Lookup](https://github.com/alifnrzm/Price-Catcher/blob/main/Pics/LookupIngest.JPG)

This process involves creating a lookup file which refer to the URL to the files stored in Github. Since there are 2 Lookup files, We uses the For each function to lookup every URL in the json file and sink files are stored in ADLS

  ```json
[
    {
        "sourceBaseURL":"https://raw.githubusercontent.com/",
        "sourceRelativeURL":"alifnrzm/Price-Catcher/main/lookup_premise.csv",
        "sinkFileName":"lookup_premise.csv"
    },
    {
        "sourceBaseURL":"https://raw.githubusercontent.com/",
        "sourceRelativeURL":"alifnrzm/Price-Catcher/main/lookup_item.csv",
        "sinkFileName":"lookup_item.csv"
    }
   
]
  ```

**Price List (Blob Storage)**

![Price](https://github.com/alifnrzm/Price-Catcher/blob/main/Pics/PriceIngest.JPG)

Ingesting the price list involves a 12 month data set from the Azure Blob Storage. Copy activity are done to merge the 12 month files together within a single pipeline. In order to refer all the 12 month files, wildcard file path are used to refer to the files.

# Data Transformation

For data transformation, Azure Dataflow are used to transform the data. In this process, a data flow is build by joining the Price dataset and the 2 lookup dataset. The data is then sorted according to the newest data and relevant columns are selected to simplify the table when we load the dataset to PowerBI.The next step was To filter any nulls that did not retun any values during joining activity.

![dataflow](https://github.com/alifnrzm/Price-Catcher/blob/main/Pics/dataflow.JPG)

![pldataflow](https://github.com/alifnrzm/Price-Catcher/blob/main/Pics/dataflowPipeline.JPG)

The pipeline is then build to store into another ADLSg2 before loading to SQL database.

# Data Loading

After transformation, The data is loaded into Azure SQL Database where we created the table first along with the Schema according to the data types.

```sql
CREATE SCHEMA pcdb
GO

CREATE TABLE pcdb.price_catcher
(
	date_pc			DATE,
	premise_code	VARCHAR(100),
	premise			VARCHAR(100),
	address			VARCHAR(500),
	premise_type	VARCHAR(100),
	district		VARCHAR(100),
	state			VARCHAR(100),
	item_code		VARCHAR(100),
	item			VARCHAR(100),
	unit			VARCHAR(100),
	price			DECIMAL(10, 2),
	item_group		VARCHAR(100),
	item_category	VARCHAR(100)
)
GO

```
 
Then a pipeline was created to to load the data in SQL database before connecting the server to PowerBI.

![SQL](https://github.com/alifnrzm/Price-Catcher/blob/main/Pics/SQLprocess.JPG)

Now all the ETL process are done we will move on to data visualisation to PowerBI. Before that refer below for the entire ADF overview

![ADF](https://github.com/alifnrzm/Price-Catcher/blob/main/Pics/ADF.JPG)

# PowerBI

A Dashboard was created to showcased the price change thorugh a date and map with bubbles representing average price for each state in Malaysia. The price is displayed in average, minumum and maximum.
Slicers were added for the user to pick the item in order to show the prices. 

![PBID](https://github.com/alifnrzm/Price-Catcher/blob/main/Pics/PBIDefault.JPG)

For example, let say the user picked, 'Barangan Segar' in the first level. In the second level, 'Ayam' Category is picked. In the third level, 'Ayam Bersih - Standard' is picked. Then the user filtered to show only those from 'Pasar Basah' premise within one month in December.
The Dashboard will then show the price change within the month, average prices of each state for that month, the visual minimum, maximum and average price for the whole country.

![PBI](https://github.com/alifnrzm/Price-Catcher/blob/main/Pics/PBI.JPG)
 



