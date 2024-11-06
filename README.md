# Audio Noise Reduction

This project provides a complete pipeline for audio processing, including noise reduction using Verilog and audio conversion using MATLAB. The main objective is to filter noise from audio signals, convert audio to binary `.data` files, and reconstruct it into `.wav` format.

## Features
- **Noise Reduction**: Verilog-based noise reduction on audio signals.
- **MATLAB Scripts**: Convert `.wav` to `.data` files and vice versa.
- **Audio Comparison**: Compare the original and filtered audio to observe the effects of noise reduction.

## How It Works

1. **Verilog Noise Reduction**: The Verilog module filters noise from an audio signal.
2. **MATLAB Conversion**: 
    - Convert a `.wav` file to a `.data` file with binary audio data.
    - Reconstruct audio from the `.data` file back to `.wav`.

## MATLAB Code

### 1. Convert `.wav` to `.data`

This MATLAB script converts an input `.wav` audio file into a `.data` file. The audio samples are converted to 16-bit integers and written in binary format.

```matlab
% Step 1: Load the audio file
[audioSamples, fs] = audioread('input_audio.wav');

% Step 2: Ensure the sample rate is as expected
if fs ~= 16000
    error('Sample rate of audio file is not 16,000 Hz as expected.');
end

% Step 3: Scale the audio data back to 16-bit integer values
audioSamples = int16(audioSamples * 32768);

% Step 4: Convert each sample to a binary string
numSamples = length(audioSamples);
binaryData = cell(numSamples, 1); % Preallocate for efficiency

for i = 1:numSamples
    % Convert each 16-bit integer to a binary string
    binaryData{i} = dec2bin(typecast(audioSamples(i), 'uint16'), 16);
end

% Step 5: Write the binary data to a .data file
fileID = fopen('audio_output.data', 'w');
for i = 1:numSamples
    fprintf(fileID, '%s\n', binaryData{i});
end
fclose(fileID);
```

###2.  Convert `.data` to `.wav`

This script reads the filtered binary data from a `.data` file, converts it back into 16-bit integers, and then reconstructs the audio into a `.wav` file.

```matlab
% Step 1: Load the filtered data from the file
fileID = fopen('filtered_output.data', 'r');
binaryData = textscan(fileID, '%s'); % Read binary strings
fclose(fileID);

% Step 2: Convert binary strings to 16-bit integer values
numSamples = length(binaryData{1});
audioSamples = zeros(numSamples, 1); % Preallocate for efficiency

for i = 1:numSamples
    % Convert binary string to signed 16-bit integer
    audioSamples(i) = typecast(uint16(bin2dec(binaryData{1}{i})), 'int16');
end

% Step 3: Normalize the audio data to range between -1 and 1 for audio playback
audioSamples = double(audioSamples) / 32768;

% Step 4: Set the correct sample rate
fs = 16000; % Corrected sample rate for a 4-second audio duration

% Step 5: Write the audio to a file
audiowrite('reconstructed_audio.wav', audioSamples, fs);

% Optional: Play the audio to verify
sound(audioSamples, fs);
```

## Audio Comparison

To compare the original and filtered sounds, you can listen to both versions and analyze the difference:

- **Original Audio**: [Download Original Audio](https://drive.google.com/file/d/12zaoclxjfx3xI8_LUxoB2lokXbpoJV9W/view?usp=sharing)
- **Filtered Audio**: [Download Filtered Audio](https://drive.google.com/file/d/1Or-MKGpYhhckNq28m_zgJrI-DjA16GMn/view?usp=sharing)
The original audio file represents the unprocessed sound, while the filtered audio file has undergone noise reduction through the Verilog-based processing pipeline.

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/yourusername/audio-noise-reduction.git
    cd audio-noise-reduction
    ```

2. Ensure you have the necessary dependencies:
    - **MATLAB** for running the conversion scripts.
    - **Verilog synthesizing tools** for noise reduction in the Verilog module.

3. Place your input `.wav` file in the project folder and ensure it has a sample rate of 16,000 Hz.

