# Deidentifying Medical Images - Made Easy

To protect people's privacy, data must be anonymized by taking out or changing any details that could be used to identify them. This makes it safe to share the data with others for various purposes across the industry/organization. Regulations like HIPAA exist to anonymize data, especially in healthcare. This anonymization process ensures information cannot be linked back to specific individuals. For instance, the human subject research data needs to be analyzed but privacy for the participants must be a top priority. De-identification helps achieve this balance.

Direct identifiers and demographics, also known as Protected Health Information (PHI), include a patient's name, address, gender, etc., and convey a patient's physical or mental health condition, or diagnosis related to that individual, as well as financial data related to healthcare like, medical records, bills, and lab results. These must be de-identified before the data is stored/shared across servers.

Deidentifying Medical Images - Made Easy aims to simplify the process of de-identifying medical images while maintaining their utility for research and analysis.


## Repository Contents

Repository Components:

- `App`
  - `API folder`: Contains the code base for Flask APIs that communicate with the front end, database, and other Python scripts.
  - `mobile app folder`: Contains the code base for a cross-platform front-end mobile app developed using the Flutter framework.
  - `Model folder`: Contains the code base for building the LLM (Large Language Model) model that identifies sensitive data in the images.
