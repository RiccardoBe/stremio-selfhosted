# Use an official Python runtime as a parent image with a more recent base
FROM python:3.10-slim-bullseye

# Set the working directory in the container to /app
WORKDIR /app

# Install build dependencies and git
RUN apt-get update && \
    apt-get install -y git gcc g++ make libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone --branch main https://github.com/RiccardoBe/MammaMia.git .

# Add Refreshed sites config by https://pastebin.com/raw/VrC4D65J (thanks!!!)
ADD https://raw.githubusercontent.com/nihon77/stremio-selfhosted/refs/heads/main/mammamia/config.json config.json
ADD https://raw.githubusercontent.com/nihon77/stremio-selfhosted/refs/heads/main/mammamia/update_domains.py update_domains.py

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Clean up build dependencies to reduce image size
RUN apt-get remove -y gcc g++ make libffi-dev && \
    apt-get autoremove -y && \
    apt-get clean

# Expose the port, for now default is 8080 cause it's the only one really allowed by HuggingFace
EXPOSE 8080

# Run run.py when the container launches
#CMD ["python", "run.py"]
CMD python update_domains.py && python run.py
