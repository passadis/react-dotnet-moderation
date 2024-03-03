// App.js
import React, { useState } from 'react';
import { BlobServiceClient } from '@azure/storage-blob';
import logoIcon from './logo-icon.png';
import './App.css';

function App() {
  const [selectedCategories, setSelectedCategories] = useState({});
  const [file, setFile] = useState(null);
  const [message, setMessage] = useState('');
  const [isCategorySelected, setIsCategorySelected] = useState(false);

  const handleCheckboxChange = (event) => {
    const { value, checked } = event.target;
    setSelectedCategories(prev => {
      const updatedCategories = { ...prev, [value]: checked };
      setIsCategorySelected(Object.values(updatedCategories).some(v => v)); // Check if at least one category is selected
      return updatedCategories;
    });
  };

  const handleFileChange = (event) => {
    const selectedFile = event.target.files[0];
    setFile(selectedFile);
    setMessage(`File "${selectedFile.name} selected !`);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    if (!file) {
      setMessage('Please select a file to upload.');
      return;
    }

    if (!isCategorySelected) {
      setMessage('Please select at least one category.');
      return;
    }

    const sasToken = process.env.REACT_APP_SAS_TOKEN;
    const storageAccountName = process.env.REACT_APP_STORAGE_ACCOUNT;
    const containerName = 'uploads';
    const blobServiceClient = new BlobServiceClient(
      `https://${storageAccountName}.blob.core.windows.net?${sasToken}`
    );

    // Concatenate the selected categories into a comma-separated string
    const categoriesMetadataValue = Object.entries(selectedCategories)
      .filter(([_, value]) => value)
      .map(([key]) => key)
      .join(',');

    const metadata = {
      'Category': categoriesMetadataValue
    };

    try {
      const containerClient = blobServiceClient.getContainerClient(containerName);
      const blobClient = containerClient.getBlockBlobClient(file.name);
      await blobClient.uploadData(file, { metadata });
      setMessage(`Success! File "${file.name}" has been uploaded with categories: ${categoriesMetadataValue}.`);
    } catch (error) {
      setMessage(`Failure: An error occurred while uploading the file. ${error.message}`);
    }
  };

  return (
    <div className="App">
      <div className="info-text">
        <h1>Welcome to the Image Moderator App!</h1>
        JPEG, PNG, BMP, TIFF, GIF or WEBP; max size: 4MB; max resolution: 2048x2048 pixels
      </div>
      <form className="main-content" onSubmit={handleSubmit}>

        <div className="upload-box">
          <label htmlFor="photo-upload" className="upload-label">
            Upload Photo
            <input type="file" id="photo-upload" accept="image/jpeg, image/png, image/bmp, image/tiff, image/gif, image/webp" onChange={handleFileChange} />
          </label>
        </div>
        <div className="logo-box">
      <img src={logoIcon} alt="Logo Icon" className="logo-icon" />
      <div className="submit-box">
        <button type="submit" disabled={!isCategorySelected} className="submit-button">Submit</button>
        </div> 
      </div>
        <div className="categories-box">
          {['people', 'inside', 'outside', 'art', 'society', 'nature'].map(category => (
            <label key={category}>
              <span>{category}</span>
              <input type="checkbox" name="categories" value={category} onChange={handleCheckboxChange} checked={!!selectedCategories[category]} />
            </label>
          ))}
        </div>

      </form>
      {message && <div className="feedback-message">{message}</div>} {/* Display feedback messages */}
      <div className="moderator-box">
        {/* Data returned from Moderator will be placed here */}
      </div>
    </div>
  );
}

export default App;
