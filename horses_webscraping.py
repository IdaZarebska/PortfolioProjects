#!/usr/bin/env python
# coding: utf-8

# In[2]:


# import libraries
import pandas as pd
import requests
from bs4 import BeautifulSoup
import re


# In[3]:


link = 'https://koniewyscigowe.pl/statystyki_koni?rasa=xx&sezon=2017'

r = requests.get(link)
html_doc = r.text
soup = BeautifulSoup(html_doc, 'lxml')
table = soup.find('table', id='statystyki_koni')
a_tags = table.find_all("a")

links = []
for link in a_tags:
    raw = link.get('href')
    if raw[0] == '/':
        ready = 'https://koniewyscigowe.pl' + raw
        links.append(ready)
r.close()    


# In[4]:


# scrap the data from the web: https://koniewyscigowe.pl
df = pd.DataFrame()

for url in links:
    r = requests.get(url)
    html_doc = r.text
    soup = BeautifulSoup(html_doc, 'lxml')
    table = soup.find('table', id='wykaz')
    headers = []
    
    for i in table.find_all('th'):
        title = i.text
        headers.append(title)
        
    mydata = pd.DataFrame(columns=headers)
    
    for j in table.find_all('tr')[1:]:
        row_data = j.find_all('td')
        row = [i.text for i in row_data]
        length = len(mydata)
        mydata.loc[length] = row
    df = pd.concat([df, mydata])
    r.close()


# In[5]:


df.to_csv('horseracing_data.csv', sep=',', encoding='utf-8', index=False)

