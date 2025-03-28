#Yash Khanolkar   yak9424   Morse code Decoder

import numpy as np
import pyaudio
import tkinter as tk
import matplotlib.pyplot as plt
import wave
import matplotlib.animation as animation
import tkinter.filedialog

# Morse Code Dictionary (Encoder)
MORSE_CODE_DICT_ENCODER = {
    # Letters
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..',

    # Numbers
    '1': '.----', '2': '..---', '3': '...--',
    '4': '....-', '5': '.....', '6': '-....', '7': '--...', '8': '---..',
    '9': '----.', '0': '-----',

    # Symbols
    ',': '--..--', '.': '.-.-.-', '?': '..--..',
    "'": '.----.', '!': '-.-.--', '/': '-..-.', '(': '-.--.', ')': '-.--.-',
    '&': '.-...', ':': '---...', ';': '-.-.-.', '=': '-...-', '+': '.-.-.',
    '-': '-....-', '_': '..--.-', '"': '.-..-.', '$': '...-..-', '@': '.--.-.',
    ' ': '/'
}

# Morse Code Dictionary (Decoder)
MORSE_CODE_DICT_DECODER = {
    # Letters
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
    '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
    '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
    '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
    '--..': 'Z',
    
    # Numbers
    '.----': '1', '..---': '2', '...--': '3', '....-': '4', '.....': '5',
    '-....': '6', '--...': '7', '---..': '8', '----.': '9', '-----': '0',
    
    # Symbols
    '.-.-.-': '.', '--..--': ',', '..--..': '?', '-.-.--': '!', '-....-': '-',
    '.-..-.': '"', '---...': ':', '-.-.-.': ';', '-..-.': '/', '..--.-': '_',
    '.----.': "'", '-...-': '=', '.-.-.': '+', '-..-': '\\', '...-..-': '$', '.--.-.': '@',
}

# Constants for Encoder
DOT_DURATION = 0.3  # Duration of a dot in seconds
SAMPLE_RATE = 16000  # sample rate
FREQ = 1000  # Frequency 

def main_menu():
    
    def open_encoder():
        main_menu.destroy()
        morse_encoder()

    def open_decoder():
        main_menu.destroy()
        morse_decoder()

    def quit_button():
        plt.close('all')  
        main_menu.quit()
        main_menu.destroy()

    main_menu = tk.Tk()
    main_menu.title("Morse Code Menu")
    main_menu.geometry("300x200")

    title_label = tk.Label(main_menu, text="Morse Code Menu")
    encoder_button = tk.Button(main_menu, text="Morse Code Encoder", command=open_encoder)
    decoder_button = tk.Button(main_menu, text="Morse Code Decoder", command=open_decoder)
    quit_button = tk.Button(main_menu, text="Quit", command=quit_button)
    
    title_label.pack()
    encoder_button.pack(pady=10)
    decoder_button.pack(pady=10)
    quit_button.pack(side=tk.BOTTOM)

    main_menu.mainloop()

def morse_encoder():			

    def generate_waveform(message):
        
        morse_code = text_to_morse(message)
        
        total_duration = 0
        for char in morse_code:
            if char == '.':
                total_duration = total_duration + 2 * DOT_DURATION
            elif char == '-':
                total_duration = total_duration + 4 * DOT_DURATION
            elif char == '/':
                total_duration = total_duration + 7 * DOT_DURATION
            elif char == ' ':
                total_duration = total_duration + 3 * DOT_DURATION

        binary_waveform = np.zeros(int(total_duration * SAMPLE_RATE), dtype=np.float32)
        sine_wave = np.zeros(int(total_duration * SAMPLE_RATE), dtype=np.float32)
        
        current_time = 0
        for char in morse_code:
            samples_per_unit = int(DOT_DURATION * SAMPLE_RATE)
            t = np.linspace(0, DOT_DURATION, samples_per_unit, endpoint=False)
            
            if char == '.':  
                start = int(current_time * SAMPLE_RATE)
                end = start + samples_per_unit
                
                binary_waveform[start:end] = 1.0
                sine_wave[start:end] = 0.5 * np.sin(2 * np.pi * FREQ * t)
                
                current_time = current_time + DOT_DURATION
                current_time = current_time + DOT_DURATION
                
            elif char == '-':
                start = int(current_time * SAMPLE_RATE)
                end = start + 3 * samples_per_unit
                
                binary_waveform[start:end] = 1.0
                
                t_sine = np.linspace(0, 3 * DOT_DURATION, 3 * samples_per_unit, endpoint=False)
                sine_wave[start:end] = 0.5 * np.sin(2 * np.pi * FREQ * t_sine)
                
                current_time = current_time + 3 * DOT_DURATION
                current_time = current_time + DOT_DURATION
                
            elif char == '/':
                current_time = current_time + 7 * DOT_DURATION
            elif char == ' ':
                current_time = current_time + 3 * DOT_DURATION

        return binary_waveform, sine_wave

    def text_to_morse(text):
        
        morse_code = ''
        for char in text.upper():
            if char in MORSE_CODE_DICT_ENCODER:
                morse_code = morse_code + MORSE_CODE_DICT_ENCODER[char] + ' '

        return morse_code.strip()

    def play_morse_audio(sine_wave):

        
        wf = wave.open('morse_code_output.wav', 'w')		
        wf.setnchannels(1)			
        wf.setsampwidth(2)			
        wf.setframerate(16000)
        
        p = pyaudio.PyAudio()
        stream = p.open(format=pyaudio.paFloat32,
                        channels=1,
                        rate=SAMPLE_RATE,
                        output=True)
        stream.write(sine_wave.tobytes())

        sine_wave_int16 = np.int16(sine_wave * 32767) 
        wf.writeframes(sine_wave_int16.tobytes())
        wf.close()
        
        stream.stop_stream()
        stream.close()
        p.terminate()

    def display_binary_waveform(binary_waveform):
        
        plt.figure(figsize=(12, 4))
        plt.title("Morse Code Signal")
        plt.xlabel("Time (sec)")
        plt.ylabel("Amplitude")
        time = np.linspace(0, len(binary_waveform) / SAMPLE_RATE, len(binary_waveform))
        plt.plot(time, binary_waveform)
        plt.ylim(-0.01, 1.01)
        plt.grid()
        plt.show()

    def play_display():
        
        message = text_entry.get()
        if message:
            binary_waveform, sine_wave = generate_waveform(message)
            
            morse_code = text_to_morse(message)
            
            morse_display.config(state=tk.NORMAL)
            morse_display.delete(1.0, tk.END)
            morse_display.insert(tk.END, morse_code)
            morse_display.config(state=tk.DISABLED)
            
            play_morse_audio(sine_wave)
            
            display_binary_waveform(binary_waveform)

    def back_to_menu():
        encoder_root.destroy()
        main_menu()

    encoder_root = tk.Tk()
    encoder_root.title("Morse Code Encoder")

    Text_Input = tk.Label(encoder_root, text="Enter Text to Convert to Morse Code:")
    text_entry = tk.Entry(encoder_root, width=30)
    play_button = tk.Button(encoder_root, text="Encode Morse Code Signal", command=play_display)
    Morse_code = tk.Label(encoder_root, text="Morse Code Display:")
    morse_display = tk.Text(encoder_root)
    back_button = tk.Button(encoder_root, text="Back to Menu", command=back_to_menu)

    Text_Input.pack()
    text_entry.pack()
    play_button.pack()
    Morse_code.pack()
    morse_display.pack()
    morse_display.config(state=tk.DISABLED)
    back_button.pack()

    encoder_root.mainloop()

def morse_decoder():
   
    def detect_morse_audio(audio_data, sample_rate, tone_freq= 1000):
        window_size = 1024
        segments = []
        prev_sine = False
        current_segment_start = None

        for i in range(0, len(audio_data) - window_size, window_size):
            window = audio_data[i:i+window_size]
            
            fft_result = np.fft.fft(window)
            freqs = np.fft.fftfreq(len(window), 1/sample_rate)
            
            peak_idx = np.argmax(np.abs(fft_result))
            peak_freq = np.abs(freqs[peak_idx])
            
            curr_sine = 950 <= peak_freq <= 1050 and np.max(np.abs(window)) > 1000

            if curr_sine and not prev_sine:
                current_segment_start = i/sample_rate
                
            elif not curr_sine and prev_sine and current_segment_start is not None:
                duration = i/sample_rate - current_segment_start
                segments.append((current_segment_start, duration))
                current_segment_start = None

            prev_sine = curr_sine

        return segments

    def play_audio(file_path):
        
        wf = wave.open(file_path, 'rb')
        p = pyaudio.PyAudio()

        stream = p.open(format=p.get_format_from_width(wf.getsampwidth()),
                        channels=wf.getnchannels(),
                        rate=wf.getframerate(),
                        output=True)

        data = wf.readframes(1024)
        while data:
            stream.write(data)
            data = wf.readframes(1024)

        stream.stop_stream()
        stream.close()
        p.terminate()
        wf.close()

    def generate_binary_signal(segments, audio_length, sample_rate):
        binary_signal = np.zeros(audio_length)
        for start_time, duration in segments:
            start_idx = int(start_time * sample_rate)
            end_idx = int((start_time + duration) * sample_rate)
            binary_signal[start_idx:end_idx] = 1
        return binary_signal

    def plot_audio_analysis(audio_data, sample_rate, segments):
        
        time = np.linspace(0, len(audio_data) / sample_rate, len(audio_data))
        fft_result = np.fft.fft(audio_data)
        freqs = np.fft.fftfreq(len(audio_data), 1/sample_rate)

        plt.figure(figsize=(12, 9))
        plt.subplot(2, 1, 1)
        plt.plot(time, audio_data, label='Audio Signal')
        plt.title('Audio Signal')
        plt.xlabel('Time (s)')
        plt.ylabel('Amplitude')

        plt.subplot(2, 1, 2)
        plt.plot(freqs[:len(freqs)//2], np.abs(fft_result)[:len(freqs)//2], label='FFT Magnitude')
        plt.title('FFT of Audio Signal')
        plt.xlabel('Frequency (Hz)')
        plt.ylabel('Magnitude')

        plt.tight_layout()
        plt.show()

    def animate_binary_signal(audio_data, segments, sample_rate):
        binary_signal = generate_binary_signal(segments, len(audio_data), sample_rate)
        time = np.linspace(0, len(audio_data) / sample_rate, len(audio_data))

        fig, ax = plt.subplots(figsize=(10, 6))
        ax.set_title('Animated Binary Wave ')
        ax.set_xlabel('Time (s)')
        ax.set_ylabel('Binary Signal')
        line, = ax.plot([], [], 'r')

        ax.set_xlim(0, time[-1])
        ax.set_ylim(0, 1.1)

        def update(frame):
            end = int(frame * len(binary_signal) / 200)
            line.set_data(time[:end], binary_signal[:end])
            return line,

        ani = animation.FuncAnimation(fig, update, frames=200, interval=50, blit=True)
        plt.show()

    def audio_to_text(segments):
        morse_chars = []
        last_end_time = 0
        current_letter = []

        for start_time, duration in segments:
            silence_duration = start_time - last_end_time
            
            if silence_duration > 1.5:
                if current_letter:
                    morse_chars.append(''.join(current_letter))
                    current_letter = []
                morse_chars.append('/')
                
            elif silence_duration > 0.5:
                if current_letter:
                    morse_chars.append(''.join(current_letter))
                    current_letter = []

            if 0.2 <= duration <= 0.4:
                current_letter.append('.')
                
            elif 0.6 <= duration <= 1.2:
                current_letter.append('-')

            last_end_time = start_time + duration

        if current_letter:
            morse_chars.append(''.join(current_letter))

        return ' '.join(morse_chars).replace(' / ', ' / ')

    def decode_morse(morse_code):
        words = morse_code.split(' / ')
        decoded_message = []

        for word in words:
            letters = word.strip().split(' ')
            decoded_word = ''.join([MORSE_CODE_DICT_DECODER.get(letter, '[?]') for letter in letters if letter])

            if decoded_word:
                decoded_message.append(decoded_word)

        return ' '.join(decoded_message)

    def load_wav_file():
        file_path = tk.filedialog.askopenfilename(
            title="Select WAV File", 
            filetypes=[("WAV files", "*.wav")]
        )
        
        if file_path:
            wf = wave.open(file_path, 'rb')

            n_channels = wf.getnchannels()
            sample_rate = wf.getframerate()
            n_frames = wf.getnframes()
            frames = wf.readframes(n_frames)

            audio_data = np.frombuffer(frames, dtype=np.int16)
            wf.close()

            segments = detect_morse_audio(audio_data, sample_rate)

            play_audio(file_path)

            plot_audio_analysis(audio_data, sample_rate, segments)
            animate_binary_signal(audio_data, segments, sample_rate)

            morse_code = audio_to_text(segments)

            decoded_message = decode_morse(morse_code)

            display.config(state=tk.NORMAL)
            display.delete(1.0, tk.END)
            display.insert(tk.END, f"Morse Code:\n{morse_code}\n\n")
            display.insert(tk.END, f"Decoded Message:\n{decoded_message}")
            display.config(state=tk.DISABLED)

    def back_to_menu():
        decoder_root.destroy()
        main_menu()

    decoder_root = tk.Tk()
    decoder_root.title("Morse Code Decoder")

    open_file = tk.Button(decoder_root, text="Load WAV File", command=load_wav_file)
    display = tk.Text(decoder_root)
    display.config(state=tk.DISABLED)
    back_button = tk.Button(decoder_root, text="Back to Menu", command=back_to_menu)

    open_file.pack()
    display.pack()
    back_button.pack()

    decoder_root.mainloop()


main_menu()
