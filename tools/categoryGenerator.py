from genericpath import isfile
from webbrowser import get
from nltk.corpus import wordnet as wn
import csv
import json
from os import path, sep
import pandas as pd
from googletrans import Translator

def create_json(path = "../resources/unigram_freq.csv"):
    """ Creates a json dump of a dictionary of words and their frequencies

    Args:
        path (str, optional): Path to file to write json file to. Defaults to "../resources/unigram_freq.csv".
    """    
    output = {}
    freqList = csv.DictReader(open(path))
    for row in freqList:
        output[row['word']] = row['count']
    with open("../resources/unigram_freq.json", 'w') as f:
        json.dump(output, f)
    return output

def load_json(path = "../resources/unigram_freq.json"):
    """ Loads a json file as a dictionary

    Args:
        path (str, optional): Path to json file to load. Defaults to "../resources/unigram_freq.json".

    Returns:
        dict: The loaded json file.
    """    
    with open(path) as f:
        return json.load(f)

def get_hyponyms(synset):
    """ Retrieves all hyponyms of a given synse

    Args:
        synset (Synset): A synset of which all hyponyms need to be retrieved.

    Returns:
        set: A set of all hyponyms of a synset
    """    
    hyponyms = set()
    for hyponym in synset.hyponyms():
        hyponyms |= set(get_hyponyms(hyponym))
    return hyponyms | set(synset.hyponyms())

def lookupCategory(cat, freqDict):
    """ Looks up and generates a csv file with the English and Dutch word, the frequence and the score this frequency gives.

    Args:
        cat (string): A category the user wants to retrieve
        freqDict (dict): A dictionary with word frequencies
    """    
    translator = Translator()
    df = pd.DataFrame(columns=["EngWord", "NldWord", "Freq", "NldWordLength", "FreqScore"])

    # Get synsets that match word and let user select synset
    synsets = wn.synsets(cat)
    if len(synsets) > 0:
        print("Select synset by typing one of the following numbers:")
        for i in range(len(synsets)):
            print("{}: {}".format(i, synsets[i]))
        n = int(input("Chosen: "))
        syn = synsets[n]
    else:
        print("No synsets found! :(")
        exit()

    # Get hyponyms
    hyponyms = get_hyponyms(syn)
    
    # Get Frequencies
    if (len(hyponyms) > 0):
        for hyponym in hyponyms:
            words = hyponym.lemma_names()[0].split("_")
            freq = 1000000000000000
            for word in words:
                if word in freqDict.keys():
                    if int(freqDict[word]) < freq:
                        freq = int(freqDict[word])
                else:
                    freq = 0
            
            engWord = ' '.join(words)
            nldWord = translator.translate(engWord, src='en', dest='nl').text
            df = df.append({"EngWord": engWord, "NldWord": nldWord, "Freq": freq, "NldWordLength": len(nldWord), "FreqScore": None, "LenScore": None}, ignore_index=True)

        split = int(len(df.index)/5)

        # Sort and assign score based on frequency
        df = df.sort_values(by=["Freq"], ignore_index=True, ascending=False) 
        for start in range(0, len(df.index), split):
            if int((start + split)/split) < 5:
                df.loc[start:start + split, "FreqScore"] = int((start + split)/split)
            else:
                df.loc[start:start + split, "FreqScore"] = 5

        # Sort and assign score based on word length
        df = df.sort_values(by=["NldWordLength"], ignore_index=True) 
        for start in range(0, len(df.index), split):
            if int((start + split)/split) < 5:
                df.loc[start:start + split, "LenScore"] = int((start + split)/split)
            else:
                df.loc[start:start + split, "LenScore"] = 5

        # Calculate total score and sort
        df["TotalScore"] = df["FreqScore"] + df["LenScore"]
        df = df.sort_values(by=["TotalScore"], ignore_index=True, ascending=False) 

        # Write to csv file
        print("\nWriting to " + cat + ".csv in the categories folder.")
        df.to_csv("../categories/" + cat + ".csv", index=False)
    
    # If no hyponyms are found do nothing 
    else:
        print("No hyponyms found! :(")
        exit()

def main():
    print("### Loading data base ###\n")
    if not (path.exists("../resources/unigram_freq.json")):
        freqDict = create_json()
    else:
        freqDict = load_json()
    
    print("Done!\n")

    print("### Getting category ###\n")
    cat = input('Type a category: ')
    lookupCategory(cat, freqDict)
     
if __name__ == "__main__":
    main()