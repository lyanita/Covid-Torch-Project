# Author: Anita Ly
# Date: February 11, 2021
# Description

#Import Modules & Packages
import pandas as pd
import streamlit as st
import numpy as np
import matplotlib.pyplot as plt
import altair as alt
import base64
import time
import datetime

def main():
    # Load Data from CSV (URL)
    csv_url = 'https://covidtracking.com/data/download/all-states-history.csv'
    df = pd.read_csv(csv_url)

    # Get User Inputs
    start_date = datetime.datetime.strptime(str(st.sidebar.date_input('Start Date', datetime.date(2020, 1, 1))),'%Y-%m-%d')
    end_date = datetime.datetime.strptime(str(st.sidebar.date_input('End Date')), '%Y-%m-%d')
    if start_date > end_date:
        st.sidebar.error("Error: end date must fall after start date")



    # Set Up Streamlist User Interface
    st.title('COVID Trakcer Web App')
    st.header("?")
    st.subheader("COVID-19 Tracking Data")

    # Create CSV Download Link
    csv = df.to_csv(index=False)
    b64 = base64.b64encode(csv.encode()).decode()
    href = f'<a href="data:file/csv;base64,{b64}" download = covid_tracking_data.csv>Download CSV File</a> (click and save as &lt;filename&gt;.csv)'
    st.markdown(href, unsafe_allow_html=True)

if __name__ == "__main__":
    #Call main function if file is ran as a script only (not as a module)
    main()

