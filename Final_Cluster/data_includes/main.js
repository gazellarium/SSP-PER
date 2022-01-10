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
Sequence( "introduction", "consent", "instruction", "practice", "begin",  randomize("stimuli_trial") , SendResults() , "end" )
;

// What is in Header happens at the beginning of every single trial
Header(

    newTimer(250)
        .start()
        .wait()
);



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

CheckPreloaded( 20 * 1000 ) // wait for up to 20 seconds
    .label("preload");
//Checks to see if all items are preloaded before beginning


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



//The 4th trial will be a practice phase
Template( "practice.csv" , row =>
// This Template command generates as many trials as there are rows in csv
// Row will iteratively point to every row in myTable.csv

newTrial ("practice" ,

    newText("پس از گوش کردن به تلفظ هر واژه با کلیک یا لمس اعداد امتیاز خود را ثبت کنید")
	.print("center at 50vw")
    .center()
    .css("font-size", "18px")
    .css("font-family","'Vazir'")
    .css("margin","20px")
    .css("text-align", "center")
    ,
    newCanvas("words", 800, 100)
        .add(   20, 30, newAudio("practiceaudio", row.Practice_Audio) )
        .add( 500, 10, newText("practice", row.Practice) )
        .print()
        .center()
        .css("font-size", "60px")
        .css("border", "solid 2px black")
        ,

    newText("rating1", "کاملا غیرطبیعی"),
    newText("rating2", "غیرطبیعی"),
    newText("rating3", "خنثی"),
    newText("rating4", "طبیعی"),
    newText("rating5", "کاملا طبیعی")
    ,
    newCanvas("label", 800, 30)
      .add( 50, 6, getText("rating1" ) )
      .add( 220, 6, getText("rating2") )
      .add( 395, 6, getText("rating3") )
      .add( 570, 6, getText("rating4") )
      .add( 730, 6, getText("rating5") )
          .print()
          .center()
          .css("font-size", "13px")
          .css("font-family","'Vazir'")
          .settings.css("border", "solid 2px grey")
          .settings.css("margin", "6px")
          .settings.css("background-color", "#E9EBEE")
        ,
    newCanvas("rate", 800, 120)
      .add( 50, 40, newText("1", "1") )
      .add( 220, 40, newText("2", "2") )
      .add( 395, 40, newText("3", "3") )
      .add( 570, 40, newText("4", "4") )
      .add( 745, 40, newText("5", "5") )
          .print()
          .log()
          .center()
          .css("font-size", "45px")
          .settings.css("border", "solid 5px grey")
          .settings.css("margin", "10px")
          .settings.css("background-color", "#c0c0c0")
        ,
        getAudio("practiceaudio").wait("first"),
// Make sure the participant has played the audio once

        newSelector("rating")
          .add( getText("1") , getText("2"), getText("3"), getText("4"), getText("5") )
        .wait()
        .print()
        .log()
// Make sure to log the participant's selection
    )

    .log( "practice" , row.Practice)
    .log("IVP", row.IVP)
// Add these two columns to the results lines of these Template-based trials
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
    newText("همانطور که دیدید، تمامی کلمات بی‌معنی و  فرضی هستند. هدف ما این است که بدانیم هر کلمه‌ به نظر شما چقدر طبیعی‌ به نظر می‌رسد. به این صورت که با فرض آن که این کلمه‌ها نام یک محصول تجاری جدید هستند، به چه میزان برای شما مورد قبول خواهند بود")
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

)

;


//The 6th trial will be the main trial in the experiment for our stimuli
Template( "experimentfinal.csv" , row =>
// This Template command generates as many trials as there are rows in csv
// Row will iteratively point to every row in myTable.csv
     newTrial ("stimuli_trial" ,

//This will interrupt the table with a counter to play some video as a break
    newVar("counter", 0).global().set(v=>v+1)
    .test.is(20)
    .success( newVideo("videofun","1_funbear.mp4").center() .print() .log() .wait() .remove())
    ,
    newVar("counter1", 0).global().set(v=>v+1)
    .test.is(50)
    .success( newVideo("videofun1","1_funcow.mp4").center() .print() .log() .wait() .remove())
    ,
    newVar("counter2", 0).global().set(v=>v+1)
    .test.is(85)
    .success( newVideo("videofun2","1_funfight.mp4").center() .print() .log() .wait() .remove())
    ,
    newVar("counter4", 0).global().set(v=>v+1)
    .test.is(115)
    .success( newVideo("videofun4","1_funcapy.mp4").center() .print() .log() .wait() .remove())
    ,
    newVar("counter5", 0).global().set(v=>v+1)
    .test.is(155)
    .success( newVideo("videofun5","1_funduck.mp4").center() .print() .log() .wait() .remove())
    ,
    newVar("counter6", 0).global().set(v=>v+1)
    .test.is(190)
    .success( newVideo("videofun6","1_funchicken.mp4").center() .print() .log() .wait() .remove())
    ,

        newCanvas("words", 800, 100)
            .add(   20, 30, newAudio("stimuliaudio", row.Stimuli_Audio) )
            .add( 500, 10, newText("stimuli", row.Stimuli) )
            .print()
            .center()
            .css("font-size", "60px")
            .settings.css("border", "solid 2px black")
        ,
        newText("rating1", "کاملا غیرطبیعی"),
        newText("rating2", "غیرطبیعی"),
        newText("rating3", "خنثی"),
        newText("rating4", "طبیعی"),
        newText("rating5", "کاملا طبیعی")
        ,
        newCanvas("label", 800, 30)
          .add( 50, 6, getText("rating1" ) )
          .add( 220, 6, getText("rating2") )
          .add( 395, 6, getText("rating3") )
          .add( 570, 6, getText("rating4") )
          .add( 730, 6, getText("rating5") )
              .print()
              .center()
              .css("font-size", "13px")
              .css("font-family","'Vazir'")
              .settings.css("border", "solid 2px grey")
              .settings.css("margin", "6px")
              .settings.css("background-color", "#E9EBEE")
            ,
        newCanvas("rate", 800, 120)
          .add( 50, 40, newText("1", "1") )
          .add( 220, 40, newText("2", "2") )
          .add( 395, 40, newText("3", "3") )
          .add( 570, 40, newText("4", "4") )
          .add( 745, 40, newText("5", "5") )
              .print()
              .log()
              .center()
              .css("font-size", "45px")
              .settings.css("border", "solid 5px grey")
              .settings.css("margin", "10px")
              .settings.css("background-color", "#c0c0c0")
            ,
            getAudio("stimuliaudio").wait("first")
            ,
            newSelector("rating")
              .add( getText("1") , getText("2"), getText("3"), getText("4"), getText("5") )
            .wait()
            .print()
            .log()
// Make sure to log the participant's selection

    )
	.log("type", row.StimuliType)
    .log("stimuli" , row.Stimuli)
    .log("IVS", row.IV)
    .log("group", row.Group)
// Add these columns to the results lines of these Template-based trials
)



// Spaces and linebreaks don't matter to the script: we've only been using them for the sake of readability

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
