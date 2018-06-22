# PocketSphinx
## Dependency

**Swig**  
    brew install swig
  
## Pre-Setup
    $ bash download.sh
Build and install SphinxBase  
  
    $ cd sphinxbase  
    $ ./autogen.sh  
    $ ./configure  
    $ make  
    $ sudo make install  

Export the environment variables to the ~/.bash_profile:
    
    export LD_LIBRARY_PATH=/usr/local/lib
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    
  

Build and install PocketSphinx  
    $ cd ../pocketspinx  
    $ ./autogen.sh  
    $ ./configure  
    $ make  
    $ sudo make install  
  
Build and install Sphinxtrain   
    $ cd ../sphinxtrain  
    $ ./autogen.sh  
    $ ./configure  
    $ make  
    $ sudo make install  
 
## Creating working directory
Create a directory
    $ mkdir kws
    $ cd kws
    
Move the mandarin acoustic model to the current work directory  
    $ mv ../zh-cn .
  
And then unarchive the file. Download the Mandarin dictionary from  
  
[https://sourceforge.net/projects/cmusphinx/files/Acoustic%20and%20Language%20Models/Mandarin/zh_broadcastnews_utf8.dic/download](http://)
     
## Creating Adaptation Corpus

Here are the files you will need:  
  
* corpus.txt
* corpus.lm
* corpus.dic
* recodings of you speaking each keyword
* corpus.fileids
* corpus.transcription
  
### corpus.txt

Write down the keywords in `corpus.txt`, one keyword in a row respectively. For example:    
    
    啟動
    暫停
    關閉
    恢復
    洞見未來
    KKBOX
    
  
### corpus.lm and corpus.dic
Then go to the [LMTool page](http://www.speech.cs.cmu.edu/tools/lmtool-new.html). Click *"選擇檔案"* to upload `corpus.txt` and click *"COMPILE KNOWLEDGE PAGE"*. Download the file followed by the extension `.lm` and `.dic`, and then change theses two files name into `corpus.lm` and `corpus.dic` respectively.  
  
### recordings

According to the previous example, you need 5 recordings and each of them records one keyword that you speak. Each recording file should be followed by the extension `.wav` recorded at the sample rate of 16k Hz in mono with a single  channel.  

### corpus.fileids

Supposed that the file name of recordings are:  
    
    voice_0001.wav
    voice_0002.wav
    voice_0003.wav
    voice_0004.wav
    voice_0005.wav
    voice_0006.wav
    
You need to create a file called `corpus.fileids` and write down:

    voice_0001
    voice_0002
    voice_0003
    voice_0004
    voice_0005
    voice_0006
    
### corpus.transcription
 
Create a file called `corpus.transcription`, write down the content of each recording row by row, and specify the file name at the  end of each row. For example:

    <s> 啟動 </s> (voice_0001)
    <s> 關閉 </s> (voice_0002)
    <s> 暫停 </s> (voice_0003)
    <s> 恢復 </s> (voice_0004)
    <s> 洞見未來 </s> (voice_0005)
    <s> KKBOX </s> (voice_0006)
    
 Make sure that, before and after the content there are an `<s>` an `</s>`, and then specify the file name of recording in the form of `(recording file name)`.
 
### Mapping the phoneme to keywords

Open the `corpus.dic` and the `zh_broadcastnews_utf8.dic` which you just downloaded. First, delete the phonemes after KKBOX, because we want to map KKBOX to phoneme from Mandarin dcitionary. Find the phoneme mapping each mandarin word you need in `zh_broadcastnews_utf8.dic`. For example, you need to find the phonemes mapping the following words: "K", "BOX", "啟", "動", "關", "閉", "暫", "停", "恢", "復", "洞", "見", "未" and "來". After finding out the corrsponding phonems, copy and paste to the `corpus.dic`. Then you should have the `corpus.dic` look like:

    KKBOX k ei k ei b a k e s
    啟動 q i d ong
    恢復 h ui f u
    暫停 z an t ing
    洞見未來 d ong x ian w ei l ai
    關閉 g uan b i
    
Besides, don't forget to put space between each phoneme.
  
  
Now, the file structure should look like:
    
    voice_0001.wav
    voice_0002.wav
    .....
    corpus.fildids
    corpus.transcription
    corpus.lm
    corpus.dic
    corpus.txt
    zh-cn
    zh_broadcastnews_utf8.dic
    
  
## Adapting the acoustic model
### Generating acoustic feature files
    
    sphinx_fe -argfile zh-cn/feat.params \
        -samprate 16000 -c corpus.fileids \
        -di . -do . -ei wav -eo mfc -mswav yes
    
You should have the following files in yours working directory:
    
    voice_0001.wav
    voice_0001.mfc
    voice_0002.wav
    voice_0002.wav
    .....
    corpus.fildids
    corpus.transcription
    corpus.lm
    corpus.dic
    corpus.txt
    zh_broadcastnews_utf8.dic
    
### Generating the mdef file
  
    pocketsphinx_mdef_convert -text zh-cn/mdef zh-cn/mdef.txt
  
### Copy the programs needed
  
    cp /usr/local/libexec/sphinxtrain/bw .
  
    cp /usr/local/libexec/sphinxtrain/map_adapt .
  
    cp /usr/local/libexec/sphinxtrain/mllr_solve .
  
### Accumulating observation counts
    
    ./bw \
    -hmmdir zh-cn \
    -moddeffn zh-cn/mdef.txt \
    -ts2cbfn .ptm. \
    -feat 1s_c_d_dd \
    -svspec 0-12/13-25/26-38 \
    -cmn current \
    -agc none \
    -dictfn corpus.dic \
    -ctlfn corpus.fileids \
    -lsnfn corpus.transcription \
    -accumdir .

### Creating a transformation with MLLR
    
    ./mllr_solve \
    -meanfn zh-cn/means \
    -varfn zh-cn/variances \
    -outmllrfn mllr_matrix -accumdir .
    
  
### Updating the acoustic model files

You now need to copy the acoustic model directory and overwrite the newly created directory with the adapted model files:
  
    cp -a zh-cn zh-cn-adapt
  
And then,

    
    ./map_adapt \
    -moddeffn zh-cn/mdef.txt \
    -ts2cbfn .ptm. \
    -meanfn zh-cn/means \
    -varfn zh-cn/variances \
    -mixwfn zh-cn/mixture_weights \
    -tmatfn zh-cn/transition_matrices \
    -accumdir . \
    -mapmeanfn zh-cn-adapt/means \
    -mapvarfn zh-cn-adapt/variances \
    -mapmixwfn zh-cn-adapt/mixture_weights \
    -maptmatfn zh-cn-adapt/transition_matrices
    
## Using the adapting acoustic model

    pocketsphinx_continuous -inmic yes -hmm zh-cn-adapt -lm corpus.lm -dict corpus.dic -mllr mllr_matrix
  
  Done!  
  
--  
Reference: [CMUSphinx](https://cmusphinx.github.io/wiki/tutorialadapt/)
 
    
