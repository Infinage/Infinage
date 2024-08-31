import streamlit as st
import pandas as pd
import zipfile
import io
import time

def process_xlsx(file):
    # Example processing: Reading and then converting to CSV (this is just a placeholder)
    df = pd.read_excel(file)

    # Simulate processing time
    time.sleep(2)  # Simulate a delay for the progress bar

    return df

def create_zip_from_dataframe(df):
    # Create a buffer to hold the zip data
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w", zipfile.ZIP_DEFLATED) as zf:
        # Convert the DataFrame to a CSV and add it to the zip file
        csv_data = df.to_csv(index=False).encode('utf-8')
        zf.writestr("processed_data.csv", csv_data)

    # Ensure the buffer is ready for reading
    buffer.seek(0)
    return buffer

def main():
    st.title("Excel to ZIP Processor")

    uploaded_file = st.file_uploader("Choose an Excel file", type="xlsx")
    if uploaded_file is not None:
        st.write("Processing the file...")

        # Show progress bar
        progress_bar = st.progress(0)

        # Call the processing function
        df = process_xlsx(uploaded_file)

        # Update progress bar
        progress_bar.progress(50)

        # Create a zip file from the processed data
        zip_buffer = create_zip_from_dataframe(df)

        # Update progress bar to 100%
        progress_bar.progress(100)

        st.write("File processed successfully!")

        # Provide download link
        st.download_button(
            label="Download ZIP",
            data=zip_buffer,
            file_name="processed_data.zip",
            mime="application/zip"
        )

if __name__ == "__main__":
    main()
