//
//  RLSpeech.m
//  FCRN
//
//  Created by 荣 li on 2018/1/15.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "RLSpeech.h"
#import <AVFoundation/AVFoundation.h>

@interface RLSpeech()<AVSpeechSynthesizerDelegate>
@property (nonatomic, strong)AVSpeechSynthesizer *speechSynthesizer; //语音合成器
@property (nonatomic, strong)AVSpeechSynthesisVoice *speechSynthesisVoice;      //语言
@property (nonatomic, strong)AVSpeechUtterance *speechUtterance;    //发声对象
@end

@implementation RLSpeech

- (void)playWithString:(NSString *)str{
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:str];
    utterance.voice = self.speechSynthesisVoice;
    utterance.rate = 0.5;
    self.isReading = YES;
    [self.speechSynthesizer speakUtterance:utterance];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"************已经说完**************");
    self.isReading = NO;
}

- (AVSpeechSynthesizer *)speechSynthesizer{
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        _speechSynthesizer.delegate = self;
    }
    return _speechSynthesizer;
}

- (AVSpeechSynthesisVoice *)speechSynthesisVoice{
    if (!_speechSynthesisVoice) {
        _speechSynthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"];
    }
    return _speechSynthesisVoice;
}
@end
