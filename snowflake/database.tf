resource "snowflake_database" "orders" {
  name = "DB_ORDERS"
}

resource "snowflake_database" "inventory" {
  name = "DB_INVENTORY"
}

resource "snowflake_warehouse" "warehouse" {
  name           = "WH_ORDERS"
  comment        = "Orders Warehouse"
  warehouse_size = "small"
}

resource "snowflake_schema" "orders" {
  database            = snowflake_database.orders.name
  name                = "HOLDING"
  data_retention_days = 1
}

resource "snowflake_table" "orders" {
  database                    = snowflake_schema.orders.database
  schema                      = snowflake_schema.Orders.name
  name                        = "table"
  comment                     = "A table."
  cluster_by                  = ["to_date(DATE)"]
  data_retention_time_in_days = snowflake_schema.schema.data_retention_time_in_days
  change_tracking             = false

  column {
    name     = "id"
    type     = "int"
    nullable = true

    default {
      sequence = snowflake_sequence.sequence.fully_qualified_name
    }
  }

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true

    identity {
      start_num = 1
      step_num  = 3
    }
  }

  column {
    name     = "data"
    type     = "text"
    nullable = false
    collate  = "en-ci"
  }

  column {
    name = "DATE"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name    = "extra"
    type    = "VARIANT"
    comment = "extra data"
  }

  primary_key {
    name = "my_key"
    keys = ["data"]
  }
}