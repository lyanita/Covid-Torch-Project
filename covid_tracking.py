# Author: Anita Ly
# Date: February 11, 2021
# Description

#Import Modules & Packages
import pandas as pd
import streamlit as st
import numpy as np
import matplotlib.pyplot as plt
import altair as alt
import plotly.express as px
import base64
import time
import datetime

def main():
    # Load Data from CSV (URL)
    csv_url = 'https://covidtracking.com/data/download/all-states-history.csv'
    df = pd.read_csv(csv_url)
    df['date'] = pd.to_datetime(df['date'], format='%Y-%m-%d')

    # Get User Inputs
    start_date = datetime.datetime.strptime(str(st.sidebar.date_input('Start Date', datetime.date(2021, 2, 1))),'%Y-%m-%d')
    end_date = datetime.datetime.strptime(str(st.sidebar.date_input('End Date')), '%Y-%m-%d')
    if start_date > end_date:
        st.sidebar.error("Error: end date must fall after start date")
    metric = st.sidebar.selectbox('Metric', ('deathIncrease', 'positiveIncrease', 'totalTestResultsIncrease'))

    # Record Start Time
    time_start = time.time()

    # Filter Data to Input Dates
    date_df = df.loc[(df['date'] >= start_date) & (df['date'] <= end_date)]

    # Set Up Streamlist User Interface
    st.title('COVID-19 Tracker Web App')
    st.subheader("Data is retrieved from the COVID Tracking Project, a volunteer organization that is dedicated to collecting and publishing data on COVID-19 testing and patient outcomes.")

    # Create a Choropleth Map
    metric_map_df = date_df.groupby(['state'], as_index=False).agg({metric: "sum"})
    map = px.choropleth(metric_map_df, locations="state", color=metric, locationmode="USA-states")
    map.update_layout(title_text="COVID-19 Measurements by State", geo_scope='usa')
    st.plotly_chart(map)

    # Create a Timeseries Plot
    metric_plot_df = date_df.groupby(['date'], as_index=False).agg({metric: "sum"})
    timeseries = px.line(metric_plot_df, x="date", y=metric)
    timeseries.update_layout(title_text="COVID-19 Trends by Date")
    st.plotly_chart(timeseries)
    #timeseries = alt.Chart(metric_plot_df).mark_line(point=True).encode(x=alt.X("date"), y=alt.Y(metric),tooltip=['date', metric]).interactive()
    #timeseries_chart = timeseries.properties(width=700, height=300)
    #st.altair_chart(timeseries_chart)

    # Create CSV Download Link
    csv = df.to_csv(index=False)
    b64 = base64.b64encode(csv.encode()).decode()
    href = f'<a href="data:file/csv;base64,{b64}" download = covid_tracking_data.csv>Download CSV File</a> (click and save as &lt;filename&gt;.csv)'
    st.markdown(href, unsafe_allow_html=True)

    # Record End Time & Calculate Time Elapsed
    time_end = time.time()
    time_elapsed = time_end - time_start
    st.write("Time Elapsed:", time_elapsed, " seconds")

if __name__ == "__main__":
    #Call main function if file is ran as a script only (not as a module)
    main()

