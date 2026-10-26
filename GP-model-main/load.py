import torchaudio


def load_audio():
    file_path = "file.ogg" 
    read, t = torchaudio.load("file.ogg")
    return read,t
