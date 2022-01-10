// Shorten command names (keep this line here)
PennController.ResetPrefix(null);
var showProgressBar = false;

//Replace the preload message
const replacePreloadingMessage = ()=>{
    const preloadingMessage = $(".PennController-PennController > div");
    if (preloadingMessage.length > 0 && preloadingMessage[0].innerHTML.match(/^<p>Please wait while the resources are preloading/))
        preloadingMessage.html("<h2> آزمون در حال بارگیری است و به زودی ادامه پیدا می‌کند... از شکیبایی شما متشکریم</h2>");
    window.requestAnimationFrame( replacePreloadingMessage );
};
window.requestAnimationFrame( replacePreloadingMessage );


//the order of trials then send the result
Sequence( "introduction", "consent", "instruction", "practice", "begin", "stimuli_trial" , SendResults() , "end" )
;


// What is in Header happens at the beginning of every single trial
Header(

    newTimer(350)
        .start()
        .wait()
)
;


// The 1st trial gives a short introduction to the experiment
newTrial("introduction" ,
    newHtml("intro", "intro.html")
        .print()
    ,
    newButton("continue", "وارد کردن اطلاعات" )
        .css("padding","0.5em")
        .css("width","400px")
        .css("font-size", "22px")
        .css("font-family","'Vazir'")
        .css("color","white")
        .css("background-color","#4267B3")
        .center()
        .log()
        .print()
        .wait()
);


// The 2nd trial asks for the participant's information
newTrial( "consent" ,
    newHtml("form", "form.html")
        .log()
        .print()
        .checkboxWarning("لطفا تیک را بزنید")
        .radioWarning("لطفا گزینه‌ای را انتخاب کنید")
        .inputWarning("لطفا پاسخ خود را در کادر بنویسید")
        .print()
,
    newButton("ثبت اطلاعات")
        .print("center at 50vw")
        .css("padding","0.5em")
        .css("width","400px")
        .css("font-size", "22px")
        .css("font-family","'Vazir'")
        .css("color","white")
        .css("background-color","#4267B3")
        .center()
        .wait(
        getHtml("form").test.complete()
            .failure( getHtml("form").warn() ))

);


//The 3rd trial gives instruction and guidance to the participant
newTrial ("instruction",

    newHtml("instructions", "instructions.html")
        .print()
    ,
    newButton("continue", "مرحله تمرینی" )
        .css("padding","0.5em")
        .css("width","400px")
        .css("font-size", "22px")
        .css("font-family","Vazir")
        .css("color","white")
        .css("background-color","#4267B3")
        .center()
        .print()
        .wait()
);

//Checks to see if all items are preloaded before beginning
CheckPreloaded( 20 * 1000 ) // wait for up to 20 seconds
    .label("preload");


//The 4th trial will be a practice phase
Template( "practice.csv" , row =>
// This Template command generates as many trials as there are rows in csv
// Row will iteratively point to every row in myTable.csv

newTrial ("practice" ,

    newText("پس از گوش کردن به تلفظ هر دو واژه، واژه‌ای که از نظر آوایی برایتان طبیعی‌تر است، کلیک یا لمس کنید")
	.print("center at 50vw")
    .center()
    .css("font-size", "18px")
    .css("font-family","'Vazir'")
    .css("margin","20px")
    .css("text-align", "center")
	,
    newCanvas("audio", 800, 80)
        .add(   20, 18, newAudio("soundl", row.PL_Audio) )
        .add( 490, 18,  newAudio("soundr", row.PR_Audio) )
        .print()
        .center()
        .settings.css("border", "solid 2px black")

,
    newCanvas("pairs", 800, 200)
        .add(   70, 60, newText("left", row.PL) )
        .add( 550, 60, newText("right", row.PR) )
        .print()
        .center()
        .css("font-size", "60px")
        .settings.css("border", "solid 5px grey")
        .settings.css("margin", "10px")
        .settings.css("background-color", "#c0c0c0")

,
  getAudio("soundl").wait("first"),
  getAudio("soundr").wait("first"),
// Make sure the participant has played the audio once

  newSelector("comparison")
    .add( getText("left") , getText("right") )
    .print()
    .wait()
    .log()
    .once()
// Make sure to log the participant's selection
)

.log("stimulil", row.PL)
.log("Ivpl", row.IVL)
.log("stimulir", row.PR)
.log("ivpr", row.IVR)
);


//The 5th trial will announce the start of the experiment
newTrial ("begin" ,

    newText("مرحله تمرینی به پایان رسید")
    .print("center at 50vw")
    .center()
    .css("font-size", "22px")
    .css("font-family","'Vazir'")
    .css("margin","20px")
    ,
    newText("همانطور که دیدید، تمامی کلمات بی معنی و  فرضی هستند. هدف ما این است که بدانیم در بین هر جفت از کلمه‌ها به نظر شما کدام طبیعی‌تر است. به این صورت که با فرض آن که این کلمه‌ها نام یک محصول تجاری جدید هستند، به چه میزان برای شما مورد قبول خواهند بود")
    .print("center at 50vw")
    .center()
    .css("font-size", "20px")
    .css("font-family","'Vazir'")
    .css("margin","20px")
    .css("text-align", "center")
    ,
    newButton("expstart","شروع آزمون")
    .center()
    .css("padding","0.5em")
    .css("width","300px")
    .css("font-size", "22px")
    .css("font-family","'Vazir'")
    .css("color","white")
    .css("background-color","#4267B3")
    .print()
    .wait()

);

CheckPreloaded("stimuli_trial", 20*1000)
.label("preload");


//The 6th trial will be the main trial in the experiment for our stimuli
Template( "experimentonset.csv" ,
// Row will iteratively point to every row in csv
    row => newTrial( "stimuli_trial" ,

//Play some videos for a break with a counter
    newVar("counter", 0).global().set(v=>v+1)
    .test.is(14)
    .success( newVideo("videofun","2_funpenguin.mp4").center() .print() .log() .wait() .remove())
    ,
    newVar("counter2", 0).global().set(v=>v+1)
    .test.is(30)
    .success( newVideo("videofun2","2_funmonkey.mp4").center() .print() .log() .wait() .remove())
    ,
    newVar("counter3", 0).global().set(v=>v+1)
    .test.is(48)
    .success( newVideo("videofun3","2_funsheep.mp4").center() .print() .log() .wait() .remove())

    ,
    newCanvas("audio", 800, 80)
        .add(   20, 18, newAudio("soundl", row.SL_Audio) )
        .add( 490, 18, newAudio("soundr", row.SR_Audio) )
        .print()
        .center()
        .settings.css("border", "solid 2px black")

,
    newCanvas("pairs", 800, 200)
        .add(   70, 60, newText("left", row.SL) )
        .add( 550, 60, newText("right", row.SR) )
        .print()
        .center()
        .css("font-size", "60px")
        .settings.css("border", "solid 5px grey")
        .settings.css("margin", "10px")
        .settings.css("background-color", "#c0c0c0")
,

    getAudio("soundl").wait("first"),
    getAudio("soundr").wait("first"),

    newSelector("comparison")
        .add( getText("left") , getText("right") )
        .wait()
        .once()
        .log()
// Make sure to log the participant's selection

)
  .log("stimulil", row.SL)
  .log("ivl", row.IVL)
  .log("stimulir", row.SR)
  .log("ivr", row.IVR)
  .log("group", row.Group)
// Add these three columns to the results lines of these Template-based trials
)
;

// The 8th trial will send the results to the server
newTrial( "end" ,
    newText("پایان آزمون")
        .print()
        .center()
        .css("font-size", "30px")
        .css("font-family","'Vazir'")
        .css("margin-top","15px")
    ,
    newText("پاسخ شما ثبت شد.   با سپاس")
        .print()
        .center()
        .css("font-size", "22px")
        .css("font-family","'Vazir'")
        .css("margin","20px")
    ,
    newButton().wait()  // Wait for a click on a non-displayed button = wait here forever
)
.setOption( "countsForProgressBar" , false )
// Make sure the progress bar is full upon reaching this last (non-)trial
