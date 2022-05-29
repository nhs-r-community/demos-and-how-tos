# Download and Process the KH03 data

Each NHS Trust has so submit a report containing the amount of beds available and occupied in a month. This report is
called "KH03", and is available (by quarter) from April 2010 onwards.

The script in this folder will download and process these files. It does not attempt to use the yearly versions which
were available prior to April 2010.

The script generates an Rds file containing the nested data, or an unnested version as a parquet file.