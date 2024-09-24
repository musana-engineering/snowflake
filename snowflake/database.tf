resource "snowflake_database" "main" {
  name = "GLOBO_LATTE_DB"
}

resource "snowflake_schema" "sales_data" {
  database = snowflake_database.main.name
  name     = "SALES_DATA"
}

resource "snowflake_warehouse" "warehouse" {
  name           = "GLOBO_LATTE_WH"
  comment        = "Sales Data Warehouse"
  warehouse_size = "small"
}

# Sales_Transactions Table
resource "snowflake_table" "sales_transactions" {
  name     = "SALES_TRANSACTIONS"
  database = snowflake_database.main.name
  schema   = snowflake_schema.sales_data.name

  column {
    name     = "TRANSACTION_ID"
    type     = "STRING"
    nullable = false
  }

  column {
    name     = "BUSINESS_UNIT"
    type     = "STRING"
    nullable = true
  }

  column {
    name     = "PRODUCT_ID"
    type     = "STRING"
    nullable = true
  }

  column {
    name     = "CUSTOMER_ID"
    type     = "STRING"
    nullable = true
  }

  column {
    name     = "QUANTITY"
    type     = "INTEGER"
    nullable = true
  }

  column {
    name     = "TOTAL_PRICE"
    type     = "FLOAT"
    nullable = true
  }

  column {
    name     = "TRANSACTION_DATE"
    type     = "TIMESTAMP"
    nullable = true
  }

  column {
    name     = "PAYMENT_METHOD"
    type     = "STRING"
    nullable = true
  }
}

# Products Table
resource "snowflake_table" "products" {
  name     = "PRODUCTS"
  database = snowflake_database.main.name
  schema   = snowflake_schema.sales_data.name

  column {
    name     = "PRODUCT_ID"
    type     = "STRING"
    nullable = false
  }

  column {
    name     = "PRODUCT_NAME"
    type     = "STRING"
    nullable = true
  }

  column {
    name     = "CATEGORY"
    type     = "STRING"
    nullable = true
  }

  column {
    name     = "PRICE"
    type     = "FLOAT"
    nullable = true
  }

  column {
    name     = "STOCK_QUANTITY"
    type     = "INTEGER"
    nullable = true
  }
}

# Customers Table
resource "snowflake_table" "customers" {
  name     = "CUSTOMERS"
  database = snowflake_database.main.name
  schema   = snowflake_schema.sales_data.name

  column {
    name     = "CUSTOMER_ID"
    type     = "STRING"
    nullable = false
  }

  column {
    name     = "CUSTOMER_NAME"
    type     = "STRING"
    nullable = true
  }

  column {
    name     = "EMAIL"
    type     = "STRING"
    nullable = true
  }

  column {
    name     = "LOCATION"
    type     = "STRING"
    nullable = true
  }
}

# Business_Units Table
resource "snowflake_table" "business_units" {
  name     = "BUSINESS_UNITS"
  database = snowflake_database.main.name
  schema   = snowflake_schema.sales_data.name

  column {
    name     = "BUSINESS_UNIT_ID"
    type     = "STRING"
    nullable = false
  }

  column {
    name     = "COUNTRY"
    type     = "STRING"
    nullable = true
  }

  column {
    name     = "UNIT_NAME"
    type     = "STRING"
    nullable = true
  }
}

// File Format
resource "snowflake_file_format" "csv_format" {
  name     = "CSV_FORMAT"
  database = snowflake_database.main.name
  schema   = snowflake_schema.sales_data.name

  format_type      = "CSV"
  field_delimiter  = ","
  skip_header      = 0
  skip_blank_lines = true
  compression      = "AUTO"
}
