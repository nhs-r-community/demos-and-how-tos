# OPCS codes

OPCS codes are hospital procedural codes that are detailed in the [NHS Dictionary](https://www.datadictionary.nhs.uk/data_elements/opcs-4_code.html#:~:text=OPCS%2D4%20CODE%20is%20the%20same%20as%20attribute%20CLINICAL%20CLASSIFICATION,identify%20the%20CODED%20CLINICAL%20ENTRY.) 
and available (upon request) from NHS Digital [TRUD](https://isd.digital.nhs.uk/trud/users/guest/filters/0/categories/37).

Although the procedures are categorised in order, this only is set out by clinical
coders at a later stage. This particular code relate to that earlier general order
prior to recoding.

The two datasets created are a dummy and based on the wide layout format with 
each procedure code appearing in its own column. The matches to the lookup table 
are based on the codes appearing in the order opcs and then procedurecode2. As 
the data has not been cleaned it can mean that whilst biopsy is code D1 followed 
by B1, the patient data could have the data appearing as B1 then D1.

The result dataset needs to have:

- patient1 with only 1 procedure listed
- patient2 has 2 categories it can join to `procedure_name` Biopsy and Wide 
incision
- patient3 has 2 categories but at later procudure columns and should join to 
Biopsy and Wide incision
- patient4 has 2 categories reversed but should also join to `procedure_name` Biospy