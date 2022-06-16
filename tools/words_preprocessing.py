# READ ALL GROUP CSV IN A DATAFRAME
import os
import pandas as pd

#create a variable and look through contents of the directory 
files=[f for f in os.listdir("categories/group") if f.endswith('.csv')]

#Initalize an empty data frame
df = pd.DataFrame()

#iterate through files and their contents, then concatenate their data into the data frame initialized above
for file in files:
    topic = file.split("_",1)[0]
    current_df = pd.read_csv('categories/group/' + file)
    current_df.insert(0, 'Topic', topic)
    df = pd.concat([df, current_df])
    #os.remove('categories/group/' + file)
    
# Sort values by frequency
df=df.sort_values('Freq', ignore_index = True, ascending=False)

# Cluster groups in 10 words
theList = df["Freq"]
value = 0
iteration = 0
subList = []
for index in range(0,len(theList)):
    subList.append(value)
    iteration += 1
    if iteration == 10:
        iteration = 0
        value += 1
df["Level"] = subList

# Delete frequency because we don't need it anymore
df = df.drop('Freq', 1)

# We can save the files with levels instead of frequencies. But we have to save a file for each topic.
for file in files:
    topic = file.split("_",1)[0]
    current_df = df.loc[df["Topic"]==topic]
    current_df = current_df.drop('Topic', 1)
    current_df.to_csv('categories/group/' + topic + '_mean_level.csv', index=False)
    
    
    
# To save activation levels, we first get values for group 0
df = df.loc[df["Group"]==0]
df = df.drop('Group', 1)
    
# We now can save this in the csv
#os.remove('activation_frequency.csv')
df.to_csv('activation_level.csv', index = False)
    