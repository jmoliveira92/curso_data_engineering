For contact please reach me in my Linkedin: https://www.linkedin.com/in/joaofmoliveira/ 

# Course_Data_Engineering
Data Enginnering course provided by Civica Software S.L. from October 2023 - December 2023 (3 months).

The project relates with an e-commerce shop, and aims to develop a BI model infrastructure to monitor and analyze the business, generate insights for increasing sales and marketing, and measure operational costs for reduction.

- The code you see in this repo is related with **DBT** transformations (build Silver/Bronze stages. I also used advanced concepts such as **incrementals** and **snapshots**).
- Check the **Power BI dashboard** on the pdf file **E-Commerce PowerBI Dashboard_pdf** in this repo.
- Check the full presentation in Tomeapp.ai: https://tome.app/oli-e3c/data-engineering-final-project-clq3yh6c80akrps77mbzwh1bt

In this project, I utilized various tools and technologies as depicted in the following image:

![Project_tools2](https://github.com/jmoliveira92/curso_data_engineering/assets/142105466/60472f86-5387-446d-a4cb-72b41bc228d9)

## Project Roadmap
In summary, the project roadmap followed the steps outlined below:

1. **Data Sources:** The sources are stored in a SQL Server along with a budget document in Google Sheets format (.xlsx).
2. **Data Warehousing with Snowflake:** In Snowflake, our Data Warehouse (DWH), I implemented the Lakehouse paradigm with three distinct databases, following the Bronze, Silver, and Gold layers. This was achieved using an ELT (Extract, Load, Transform) approach.
3. **Data Exploration:** I conducted data exploration in Snowflake to familiarize myself with the database. This step helped me to understand the required modeling and transformations to build the Silver and Gold layers.
4. **Bronze Layer:** For the Bronze layer, I imported data from SQL Server using Fivetran to populate the Snowflake Bronze database.
5. **dbt Modeling:** I used dbt (data build tool) to model the data and perform necessary transformations for the different layers. Note: The Bronze and Silver layers are in the Development environment, while the Gold (final) layer is in the Production environment.
6. **Power BI Integration:** After data modeling, I imported the project from Snowflake to Power BI via "Direct Query." In Power BI, I created visualizations to address the initial questions posed at the beginning of the project (check the presentation to more information).

## Initial Database
![bd_original1](https://github.com/jmoliveira92/curso_data_engineering/assets/142105466/192a0a54-029e-4f8c-b49f-77a1bfd42b7c)

## Extended Dabatase
In order to enrich the model, I added more business concepts, namely: product purchase costs, shipping costs (contract that stipulates $/lbs with service providers), price history, accounting (operational and structural costs), salaries .

## Code Examples

### Intermediate Model
![code_int_models](https://github.com/jmoliveira92/curso_data_engineering/assets/142105466/702cc8df-aa45-443b-ab69-db43ab5f1f59)

### Fact Orders
![code_fact_orders](https://github.com/jmoliveira92/curso_data_engineering/assets/142105466/38f812c8-02b9-4839-9d00-731c518e53c4)

## Power BI Example
![sales_power BI](https://github.com/jmoliveira92/curso_data_engineering/assets/142105466/b90f4aea-99c6-4662-aad4-55960b4c7f4d)



