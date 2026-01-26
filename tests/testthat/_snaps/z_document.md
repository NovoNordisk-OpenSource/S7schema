# document_schema() - output is consistent

    Code
      cat(expect_s3_class(expect_type(document_schema(test_path("schemas",
        "simple.json"), 1), "character"), "knit_asis"))
    Output
      # Simple example
      
      Simple example schema
      
      |Type   |Additional Properties |
      |:------|:---------------------|
      |object |No                    |
      
      ## Properties
      
      |Name         |Description         |Type    |Required |
      |:------------|:-------------------|:-------|:--------|
      |id           |ID                  |string  |No       |
      |do_something |Boolean for testing |boolean |No       |

---

    Code
      cat(expect_s3_class(expect_type(document_schema(test_path("schemas",
        "definitions.json"), 1), "character"), "knit_asis"))
    Output
      # Complicated example for testing
      
      Test example with different type of definitions
      
      |Type   |Required   |Additional Properties |
      |:------|:----------|:---------------------|
      |object |id<br>keys |Yes                   |
      
      ## Properties
      
      |Name         |Description                 |Type                |Required |
      |:------------|:---------------------------|:-------------------|:--------|
      |id           |ID                          |string              |Yes      |
      |keys         |Key variables               |[keys](#keys)       |Yes      |
      |do_something |Boolean for testing         |[nested/do_something](#do_something)|No       |
      |extra        |Additional named properties |[extra](#extra)     |No       |
      
      # Definitions
      
      ## keys
      
      Keys are either single string or array of strings
      
      |Type   |Items  |Min Items |Unique Items |
      |:------|:------|:---------|:------------|
      |array  |string |1         |Yes          |
      |string |       |          |             |
      
      ## extra
      
      |Type   |
      |:------|
      |object |
      
      ## nested
      
      ### do_something
      
      Nested definition
      
      |Type    |
      |:-------|
      |boolean |

