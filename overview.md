# COVID Tracking Project Data Analysis

## Overview
The SQL file contains a series of queries that perform the following analyses:
- The total number of tests performed as of yesterday in the United States.
- The 7-day rolling average number of new cases per day over the last 30 days.
- The 10 states with the highest test positivity rate (positive tests / tests
  performed) for tests performed in the last 30 days.
  
For the above analyses, the max date in the data set is 2021-02-09. All calculations were completed with the assumption that the max date is the latest date.

All SQL-related analyses were written using mySQL Workbench.

The Python file contains a script that graphs a selected metric via a choropleth map and a line chart. The data is visualized using [Streamlit][streamlit_app].

[streamlit_app]: https://share.streamlit.io/lyanita/covid-torch-project/covid_tracking.py