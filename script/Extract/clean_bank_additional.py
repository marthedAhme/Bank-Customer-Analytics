import pandas as pd

# 1. Read the original file (handling semicolons and quotations)
df = pd.read_csv('C:/SQL_DB/Projects/Bank_analysis/bank_marketing/bank-additional/bank-additional/bank-additional.csv', sep=';', quotechar='"')

# 2. Save the file in standard CSV format (comma separated, without annoying quotation marks)
# Numbers and text will be saved as they are without " marks
df.to_csv('bank_cleaned.csv', index=False, sep=',', encoding='utf-8')

print("bank_cleaned.csv has been cleaned and saved successfully.")
