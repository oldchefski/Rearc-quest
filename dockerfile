# Use an official Node.js runtime as a parent image
FROM node:10

# Set the working directory in the container
WORKDIR /usr/questapp

# Copy package.json and package-lock.json to the working directory
COPY nodejs/package*.json ./

# Install Node.js dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY nodejs/ .

# Expose the port your app runs on
EXPOSE 3000

# Command to run your application
CMD ["node", "src/000.js"]
