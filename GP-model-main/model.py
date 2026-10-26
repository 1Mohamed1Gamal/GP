from torchaudio.transforms import Resample
import torchaudio
import numpy as np
import torch
import pronunciationTrainer

transform = Resample(orig_freq=48000, new_freq=16000)


real_text = 'Hello there i hope you are good do you see the wolf eat the girl'

trainer = pronunciationTrainer.getTrainer('hubert')

def predict(audio_file):
    return trainer.processAudioForGivenText(audio_file, real_text)

