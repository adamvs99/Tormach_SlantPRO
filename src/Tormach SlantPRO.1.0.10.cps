/**
Copyright (C) 2012-2013 by Autodesk, Inc.
All rights reserved.

Tormach 15LSlantPRO Lathe post processor configuration.
Changes for Tormach 15LSlantPRO Lathe: Copyright (C) 2015 Adam Silver
Tormach 15LSlantPRO Lathe: initial thread depth algorithm: Copyright (C) 2014 Tormach, Inc.
$Revision: 00001 $
$Date: 2016-02-03 20:14:20 +0200 (to, 02 mar 2016) $

FORKID {88B77760-269E-4d46-8588-30814E7AC681}

Changes:
2015-27-07 : OnCyclePoint: var external = getParameter("operation:turningMode") == "outer" ? true : false;
             Added support for gang tooling
2015-11-08 : Revamped maximumSpind;eSpeed to take the operation value over the default.
             Fixed gang tool exit on last gang tool call - added 'g_currToolIsGang'
2015-15-08 : improved logic to determine inital X and Z moves in an op. X before Z if first Z below
             'stock-upper-z'level
2015-02-09 : fixed a linear motion bug where G94/95 wasn't being generated when feed rates are used
             for rapid motion
2015-15-09 : added detection for errant M4s
2015-17-09 : added support for tools that cut from the +X side of the part, eg, turret tools
2015-09-11 : fixed mm/min for surface speed.
             fixed logic in selecting spindle speed for setting up CSS
2015-18-11 : fixed threading values for HSM users
2015-19-11 : removed 'useRadius' 'using_QCTP' properties ( deprecated ).
             Add support for 'Action's from local files
2015-20-11 : Commented out all 'debugOut's
             Fixed: first line of 'action' file not being displayed.
             Added _calcCT - calculates cycle times for imported code.
2015-21-11 : Replaced 'g_bigOlNumber' with javascript 'Infinity'
             re-factored all the 'action' code
             Added 'toolInfo' array. action now can look up binding ops
             for tool info, rpm, etc.
             Fixed bug calculating total cycle time.
             Fixed possible bug with gang tool between op G30 generation.
             Fixed threading Z report always zero.
2015-23-11 : Re-edited under Netbeans, fixed lexical errors.
2015-24-11 : Removed the active feed code that isn't used
2015-27-11 : Encapsulated tool comment generation
             Moved ToolInfo code to top of post.
2015-03-12 : replaced boolean tests against 'turret' with toolInfo.toolType.
             added 'tormachMillLathing' property - minimal support for lathing on Tormach Mill.
2015-04-12 : Very wierd bug where the ToolInfo[0].toolNum is being corrupted with the tool number fomr ToolInfo[1].
             No tool header or tool call was being invoked because an tool change between sections wasn't being detected.
             Solution is a hack for now.
2015-04-12 : Above bug fixed: getToolInfo: '! sectionId' does NOT mean 'sectionId === undefined'
2015-05-12 : Added 'Document' and 'CAM' to intital header
2015-08-12 : Added '_getToolX' for helping get minimum 'X' values for internal cutting ops. Helps
             to setup boring bars, internal threading.
             Removed control variable for threading, replaced with 'isFirstCyclePoint'.
             Fixed logic error in lathe mode prompt ( QCTP, GANG, TURRET).
2015-24-12 : Added normal text passThroughs.
2015-31-12 : encapsulated: 'spindle', 'retract', 'coolant', 'tooling'
2016-03-01 : encapsulated: the 'feedType', 'optionalSection', 'endingRadiusCompensation' global vars ;
             did some code clean-up in 'onSection', 'onClose', 'writeParkTool'.
2016-06-01 : MinGangZ calcs on deltas of gang tool lengths not actual tool length.
             Multi line support for passThroughs
2016-08-01 : some more cleanup in 'onOpen', added 'lineNumber' object
2016-11-01 : fixed 'PassThrough's on inital section ( for looping )
2016-18-01 : fixed bug on writing G30 before first tool call
2016-20-01 : Added 'warnings' buffer object
2016-23-01 : Fixed: No G96/G97 or clamp on 'tormachMillLathing'; no G95 on 'tormachMillLathing'
2016-29-01 : Fixed: fails if action name can't be matched - no ToolInfo, no currentSection
2016-21-02 : Fixed: won't work on MAC. properties.writeToolinfo changed to properties.writeToolingInfo - these names can;t be the same!
2016-23-02 : Fixed: G4 - Pxxx outputs in milliseconds, not seconds.
2016-28-02 : Removed: bounding '%' lines.
             Fixed: last G30 in gang tool mode no longer writes an M0.
2016-02-03 : Added: property.partLoadTime. This adds to total cycle time. Total cycle time also put in terms of hours.
             Added; Loop state object to keep track of looping and not issue final M0 if in a loop.
             Removed : No M0s generated is a pure gang tool setup.
             Moved: 'writeG30' to the tools 'collection'.
             Added: error is constant surface speed is detected in tormachMillLathing

== OUTSTANDING ISSUES =======================================================================================
2016-29-01 : Add Warning on retractinto X that is less than cutting min diam of boring bar
2016-28-02 : Add special case for gang tool setup .. no M0s
*/

var g_description = "Tormach 15LSlantPRO-1.1.17";
vendor = "Adam Silver";
vendorUrl = "http://www.autodesk.com";
legal = "Copyright (C) 2012-2013 by Autodesk, Inc. ; (C) 2015-2016 Adam Silver ; Algorythm for calculating initial thread depth: (C) 2015 Tormach, Inc.";
certificationLevel = 2;
minimumRevision = 24000;

extension = "nc";
programNameIsInteger = false;
setCodePage("ascii");

capabilities = CAPABILITY_MILLING | CAPABILITY_TURNING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion



//user-defined properties
properties = {
    writeMachine: true,             // write machine
    showSequenceNumbers: false,     // show sequence numbers
    sequenceNumberStart: 10,        // first sequence number
    sequenceNumberIncrement: 1,     // increment for sequence numbers
    rapidFeed: 60,                  // 60 IPM on Tormach??
    manualToolChangeTime: 45,       // seconds to change a tool
    optionalStop: true,             // optional stop
    separateWordsWithSpace: true,   // specifies that the words should be separated with a white space
    maximumSpindleSpeed: 1600,      // specifies the maximum spindle speed for any op
    using_GangTooling: true,        // uses gang tooling
    tormachMillLathing: false,      // turn on if using Tormach mill as vertical lathe
    forceX_first_onFirstMove: true, // forces the X value to be the first block on the initial move
    showNotes: false,               // specifies that operation notes should be output.
    debugOutput: false,             // prints debugging info in post
    gangToolSafeMargin: 1,          // the extra margin for gang tool pull back
    writeToolingInfo: true,         // prints out the tool info header
    warnings: true,                 // issues a warning is something is found out of kilter
    partLoadTime: 65,               // time it takes to reload a part in the holding device ( in seconds )
//  actionsFilePath : "C:\\Users\\Public\\Documents\\Autodesk\\Inventor HSM 2015\\Actions",             // actions code file folder     
//  passThroughFilePath : "C:\\Users\\Public\\Documents\\Autodesk\\Inventor HSM 2015\\PassthroughCode"  // pass through code file folder    
    actionsFilePath : "/Users/adamvs/Autodesk/Fusion 360 CAM/Actions",             // actions code file folder     
    passThroughFilePath : "/Users/adamvs/Autodesk/Fusion 360 CAM/PassthroughCode"  // pass through code file folder    
};

//--------------------------------------------------------------------------------------------------------------
// encapsulate info about extern gcode files being used in 'action'.

function extFileRec( tooling, binding, type, modifer ) {
    this.binding = String( ( binding !== undefined ) ? binding : "" );
    this.type = ( type !== undefined ) ? type : "";
    this.tool = "";
    this.modifier = ( modifer !== undefined ) ? modifer : "suppress";
    this.maxZ = Infinity;
    this.minX = Infinity;
    this.ct = 0;
    this.css = true;
    this.rpm = 750;
    this.M3 = false;
    this.M5 = false;
    this.M8 = false;
    this.M9 = false;
    this.data = new Array( );
    this.toolInfo = tooling.findToolFromSectionName( this.binding );
    this.rawfile;
    
    //---member functions-------------------------------
    this.hasData =  function( ) { return this.data.length; };
    this.noData =   function( ) { return this.data.length === 0; };
    this.noBindingFound = function( ) { return this.toolInfo === undefined; };
    //---private function ------------------------------
    this._findTool = function ( ) {
//      debugOut( " _findTool: " + " rawfile: " + this.rawfile );
        var items = String( this.rawfile ).match( new RegExp( /[T][0-9]+[0-9]?/ ) );
        if ( items && items.length >= 1 )  {
            var ts = items[ 0 ];
            this.tool = parseInt( String( ts ).slice( 1, 3 ) );
        }
    };

    this._calcCT = function ( ) {
        // start at some G30
        // assume G90 for now...
//      debugOut( " _calcCT: toolInfo : "  + this.binding );
        var rpm = ( this.toolInfo && this.toolInfo.valid( ) ) ? this.toolInfo.rpm : 750;
        var feedtype = ( this.toolInfo && this.toolInfo.valid( ) ) ? this.toolInfo.feedMode : 95;
        var surfaceSpeed = ( this.toolInfo && this.toolInfo.valid( ) ) ? this.toolInfo.surfaceSpeed : 250;
        var factor = unit === MM ? 25.4 : 1;
        var _x = ( this.toolInfo && this.toolInfo.valid( ) ) ?  this.toolInfo.toolCuttingDir === toolType.XMINUS ? -2 : this.toolInfo.toolCuttingDir === toolType.XPLUS ? 2 : 0 : 0;
        var _z = 4.5;
        var _g = 0;
        var _rapid = properties.rapidFeed * factor;
        var _f = _rapid;
        var re = new RegExp( /[gGxXyzZiIkKrRpPfF][-+]?[0-9]*\.?[0-9]+/g );
        // get an average diameter for CSS, so that some reasonable RPM can be gotten.
        if ( feedtype === 95 ) {
            var x_total = 0;
            var x_count = 0;
            var x_av = 0;
            var x_items = String( this.rawfile ).match( new RegExp( /[Xx][-+]?[0-9]*\.?[0-9]+/g ) );           
            for ( var x in x_items )  {
                x_total += Number( String( x_items[ x ] ).substr( 1 ) );
                ++x_count;
            }
            x_av = ( x_count > 0 ) ? x_total / x_count : 1;
            rpm = surfaceSpeed / ( ( Math.abs( x_av ) * Math.PI ) / ( unit === MM ? 1000 : 12 ) );
//          debugOut( " _calcCT: name: " + this.binding + " x_av: " + x_av + " x_count: " + x_count + "  surfaceSpeed: " + surfaceSpeed + " rpm: " + rpm );
        }
        
        _x *= factor;
        _z *= factor;
//      debugOut( " _calcCT: " + " initial x: " + _x + "  feedtype: " + feedtype );

        for ( var i in this.data ) {
            var codes = String( this.data[ i ] ).match( re );
            var deltaX = 0;
            var deltaZ = 0;
            var _i = 0;
            var _k = 0;
            var _m = 0;
            var timeInSeconds = 0;
            
//          debugOut( " _calcCT : line= " + data[ i ] );
            for ( var j in codes ) {
                var code = String( codes[ j ] ).toUpperCase( );
                var codeType = code.charAt( 0 );
                var val = Number( String( codes[ j ] ).substr( 1 ) );
                
//              debugOut( " _calcCT : code = " + code + " type = " + codeType + " ... code Val = " + val );
                switch ( codeType ) {
                    case 'G':
                        // stick in this modal group...
                        if ( val >= 0 && val <= 4 )
                            _g = val;
                        if ( val === 94 || val === 95 )
                            feedtype = val;
                        break;
                    case 'X':
                        deltaX = Math.abs( _x - val );
                        _x = val;
                        break;
                    case 'Z':
                        deltaZ = Math.abs( _z - val );
                        _z = val;
                        break;
                    case 'F':
                        // _f needs to be in units per minute...
                        _f = ( feedtype === 94 ) ? val : val * rpm;
                        break;
                    case 'I': _i = val; break;
                    case 'K': _k = val; break;
                    case 'M': _m = val; break;
                    case 'P': if ( _g === 4 || _m !== 0 ) timeInSeconds = val; break;
                }
            } // for j in codes
            // eval the time
            deltaX /= 2;                        // we're dealing with radial movements not diameter.
            var length = deltaX + deltaZ;       // the 'nand' case
            
            if ( deltaX > 0 && deltaZ > 0 )     // the 'and' case
                length = Math.sqrt( ( deltaX * deltaX ) + ( deltaZ * deltaZ ) );
                
            // cheapo approximation of arcs .. just add 15%
            if ( _g === 2 || _g === 3 )
                length *= 1.15;
                
            if ( _g === 0 )
                timeInSeconds += length / _rapid * 60;
            else if ( _f > 0 && _g !== 4 && _m === 0 )
                timeInSeconds += length / _f * 60;
//          debugOut( "_caltCT : G" + _g + "  F" + _f + " rpm: " + rpm + " .. length = " + length + " I:" + _i + " timeInSeconds: " + timeInSeconds );
            this.ct += timeInSeconds;
        }
//      debugOut( "_caltCT : ct" + this.ct );
    };

    this._findLeastZ = function(  ) {
        var items = String( this.rawfile ).match( new RegExp( /[Zz][-+]?[0-9]*\.?[0-9]+/g ) );           
//      debugOut( " _findLeastZ: " + " rawfile: " + this.rawfile );
        for ( var i in items )
            this.maxZ = Math.min( this.maxZ, String( items[ i ] ).substr( 1 ) );
    };
    
    this._findLeastX = function(  ) {
        // this is valuable if using a boring bar clos to it's min bore spec.
        var items = String( this.rawfile ).match( new RegExp( /[Xx][-+]?[0-9]*\.?[0-9]+/g ) ); 
        var xSide = ( this.toolInfo && this.toolInfo.valid( ) ) ?  this.toolInfo.toolCuttingDir === toolType.XMINUS ? -1 : this.toolInfo.toolCuttingDir === toolType.XPLUS ? 1 : 0 : 0;
        
        // if its a gang tool .. minX is always zero...
        if ( this.toolInfo.turningMode === "inner" ) {
            for ( var i in items )
                this.minX = Math.min( this.minX, String( items[ i ] ).substr( 1 ) );
        }
        if ( this.minX === Infinity )
            this.minX = 0;
        this.minX *= xSide;
    };

    this._parseMCodes = function(  ) {
        var items = String( this.rawfile ).match( new RegExp( /[mM][35789]/g ) );    
//      debugOut( " _parseMCodes: " + " items: " + items.length );
        for ( var i in items ) {
            String( items[ i ] ).toUpperCase( );
            switch ( items[ i ] ) {
                case "M3": this.M3 = true; break;
                case "M5": this.M5 = true; break;
                case "M7": case "M8": this.M8 = true; break;
                case "M9": this.M9 = true; break;
            }
        }
//      debugOut( " _parseMCodes: " + " M3?:" + this.M3 + " M5?:" + this.M5 + " M8?:" + this.M8 + " M9?:" + this.M9 );
    };
    
    this.insertCoolant = function( coolantStr ) {
        var re = new RegExp( /[Zz][-+]?[0-9]*\.?[0-9]+/ );
        for ( var line in this.data ) {
            if ( String( this.data[ line ] ).match( re ) )  {
                this.data[ line ] = this.data[ line ] + " " + coolantStr;
                return;
            }
        }
    };                  
}  // end 'function extFileRec'


var permittedCommentChars = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.[]*&%#@!|/:;=_-";

var gFormat = createFormat({prefix:"G", decimals:1});
var mFormat = createFormat({prefix:"M", decimals:1});


var spatialFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true});
var xFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true, scale : 2 }); // diameter mode
var xrFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true }); // diameter mode
var iFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true}); // radius mode
var zFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true});
var rFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true}); // radius
var pFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true}); // thread pitch
var iThreadFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true}); // thread offset fro drive line
var jThreadFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true}); // thread initial thread depth
var kThreadFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true, scale:2 }); // thread depth, diameter mode
var kTapFormat = createFormat({decimals:(unit === MM ? 3 : 4), forceDecimal:true }); // thread pitch
var rThreadFormat = createFormat({decimals:1, forceDecimal:true, zeropad:true});
var qThreadFormat = createFormat({decimals:1, forceDecimal:true, zeropad:true});
var hThreadFormat = createFormat({decimals:0});
var feedFormat = createFormat({decimals:(unit === MM ? 4 : 5), forceDecimal:true});
var toolFormat = createFormat({decimals:0, width:4, zeropad:true});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-99999.999
var dwellFormat = createFormat({decimals:2, forceDecimal:true}); // milliseconds // range 1-9999
var taperFormat = createFormat({decimals:1, scale:DEG});
var timeFormat = createFormat({width:2, zeropad:true, decimals:0});
var infoFormat = createFormat({decimals:4});

var xOutput = createVariable({prefix:"X"}, xFormat );
var xrOutput = createVariable({prefix:"X"}, xrFormat );
var zOutput = createVariable({prefix:"Z"}, zFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var dOutput = createVariable({prefix:"D", force:true}, rpmFormat);
var pOutput = createVariable({prefix:"P", force:true}, pFormat);
var iThreadOutput = createVariable({prefix:"I", force:true}, iThreadFormat);
var jThreadOutput = createVariable({prefix:"J", force:true}, jThreadFormat);
var kThreadOutput = createVariable({prefix:"K", force:true}, kThreadFormat);
var kTapOutput = createVariable({prefix:"K", force:true}, kTapFormat);
var rThreadOutput = createVariable({prefix:"R", force:true}, rThreadFormat);
var qThreadOutput = createVariable({prefix:"Q", force:true}, qThreadFormat);
var hThreadOutput = createVariable({prefix:"H", force:true}, hThreadFormat);

//circular output
var kOutput = createReferenceVariable({prefix:"K", force:true}, zFormat);
var iOutput = createReferenceVariable({prefix:"I", force:true}, iFormat); // no scaling

var g92ROutput = createVariable({prefix:"R"}, zFormat); // no scaling

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 3 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 4 // G90-91 // only for B and C mode
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G98-99 / G94-95
var gSpindleModeModal = createModal({}, gFormat); // modal group 5 // G96-97
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({}, gFormat); // modal group 10 // G98-99
var gDiamModal = createModal({}, gFormat); // modal group 10 // G07

//fixed settings
var ge = { BINDING : 0, TYPE : 1, NAME : 2, MODIFIER : 3 };
var toolType = { NOTYPE : -99, XMINUS : -1, GANG : 0, XPLUS : 1 };
var tool30Type = { NORMAL : 0, ZONLY : 1 };
var pState = { OPENING : 0, IN_SECTIONS : 1, LAST_SECTION: 2, CLOSING: 3 };

//--------------------------------------------------------------------------------------------------------------
// encapsulate the array of external files used in actions.
function actionsInfo ( tooling, warnings ) {
    this.actions = [ ];
    this.toolingCollectionRef = tooling;

    
    
    this._stowFileData = function( parms, folder ) {
        var lines = [ ];
        var action = new extFileRec( this.toolingCollectionRef, parms[ ge.BINDING ], "action", parms[ ge.MODIFIER ] );
    
        action.rawfile = _onGetLocalTextFile( folder, parms[ ge.NAME ], action.data );
        if ( action.noData( ) )
            return;
        if ( action.noBindingFound( ) ) {
            warnings.pushWarning( " Section: '" + parms[ ge.BINDING ] + "' not found to bind." );
//          error(localize(  " Section: '" + parms[ ge.BINDING ] + "' not found to bind."  ) );
            return;
        }
        action._findLeastZ( );
        action._findLeastX( );
        action._calcCT( );
        action._findTool( );
        action._parseMCodes( );
        this.actions.push( action );

    };
    
    this.stowAction = function( actionString ) {
        var items = String( actionString ).split( ":" );
        if ( items.length < 3 && items.length > 4 )
            error(localize( "actions are BindingName:Type:Data[:actionType] - Eg, BarPull:file:barpull6.nc" ) );
        // if no modifier create a default//
        switch ( items[ ge.TYPE ] ) {
            case "file":
                // if no modifier then default to suppress.
                if ( items.length === 3 )
                    items.push( "suppress" );
                this._stowFileData( items, properties.actionsFilePath );
                break;
        }
    };

    this.findActionRec = function( name ) {
        var nameItems = String( name ).split( ":" );        
        for ( var i in this.actions ) {
//      debugOut( " finding - g_actions[ i ].binding" + g_actions[ i ].binding + " name: " + name );
            if ( this.actions[ i ].binding === nameItems[ nameItems.length - 1 ] )
                return this.actions[ i ];
        }
//      debugOut( " findActionRec:" + name + "  NOT found!" );
        return undefined;
    };
    
    this.findActionForCurrentSection = function ( ) {
        if ( currentSection )
            return this.findActionRec( currentSection.getParameter( "operation-comment" ) );
        return undefined;
    };
    
    this.postActionData = function( ) {//  debugOut( "**postActionData: op-comment: " + currentSection.getParameter( "operation-comment" ) );
        var action = this.findActionForCurrentSection( );
        _postLocalTextFile( action.data );
    };
    
    this.insertActionCoolant = function( coolantType ) {
        if ( coolantType !== COOLANT_THROUGH_TOOL && coolantType != COOLANT_FLOOD )
            return;
        var action = this.findActionForCurrentSection( );
//  debugOut( "insertActionCoolant : data: " + action.data );
        if ( ! action || action.M8 === true )
            return;
    // there was no M8 in the imported file, but the tool is set for coolant
    // iterate through the gcode at append M8 at the first 'Z' movement.
        var coolantStr = coolantType === COOLANT_THROUGH_TOOL ? "M88" : "M8";
        action.insertCoolant( coolantStr );
    };
    
    this.getActionModifier = function( section ) {
        if ( section === undefined )
            section = currentSection;
        if ( section ) {
            var action = this.findActionRec( section.getParameter( "operation-comment" ) );
            if ( action )
                return action.modifier;
        }
        return "";
    };

    this.actionIsSuppress = function( section ) { return this.getActionModifier( section ) === "suppress"; };
    this.actionIsPrepend = function( section ) { return this.getActionModifier( section ) === "prepend"; };
    this.actionIsAppend = function( section ) { return this.getActionModifier( section ) === "append"; };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate special information about tools used beyond the 'postprocessors' tool data.
function toolRecord ( section_Id, warnings ) {
    // create an 'empty' object
    this.sectionId = -1;
    this.sectionName = "";
    this.sectionMatchName = "";
    this.toolNum = 0;
    this.toolCuttingDir = undefined;
    this.toolType = undefined;
    this.toolOnGangPlate = false;
    this.toolDiam = 0;
    this.feedMode = undefined;
    this.spindleMode = undefined;
    this.surfaceSpeed = 0;
    this.turningMode = "outer";
    this.isDrill = false;
    this.isTurningTool = true;
    this.orientation = 0;
    this.clampRPM = 0;
    this.rpm = 0;
    this.toolLength = 0;
    this.maxToolNum = 26; // DO NOT CHANGE
    this.compOffset = 0;
    this.tool30Type = tool30Type.NORMAL;
    this.c_barPullerToolNum = 26; // DO NOT CHANGE
    this.isLastTool = false;
    this.toolIsNewTool = true;

    
    if ( section_Id < 0 || section_Id >= getNumberOfSections( ) )  {
        error( " toolRec - ctor : sectionId out of range " );
        return;
    }
   
    var section = getSection( section_Id );
    var secName = section.getParameter( "operation-comment" );
    var tool = section.getTool( );
    var isLastSection = section_Id === getNumberOfSections( ) - 1;
    var prevSection = section_Id > 0 ?  getSection( section_Id - 1 ) : undefined;
    
    if ( tool.getSpindleMode( ) == SPINDLE_CONSTANT_SURFACE_SPEED && properties.tormachMillLathing )
        warnings.pushWarning( " Tool: " + tool.number + " Constant Surface Speed not supported in mill lathing." );       
 
    this.sectionId = section_Id;
    this.sectionName = section.getParameter( "operation-comment" );
    
    var nameItems = String( secName ).split( ":" ); 
    if ( nameItems.length > 0 )
        this.sectionMatchName = new String( nameItems[ nameItems.length - 1 ] );
//  debugOut( " toolRecord ctor: sectionMatchName: " + this.sectionMatchName )
    this.toolNum = tool.number;
    this.isDrill = tool.isDrill( );
    this.isTurningTool = tool.isTurningTool( );
    // #KLUDGE
    if ( isStockTranferOp( section ) )
        this.toolNum = this.c_barPullerToolNum;
    if ( section.hasParameter( "operation:turningMode") && section.getParameter( "operation:turningMode" ) === "inner" )
        this.turningMode = "inner";
    this.toolCuttingDir = tool.turret > 0 ? toolType.XPLUS : tool.manualToolChange ? toolType.XMINUS : toolType.GANG;
    // #KLUDGE
    if ( this.toolCuttingDir === toolType.GANG )
        this.toolOnGangPlate = true;
    else if ( tool.comment.length > 0 ) {
        var comment_items = String( tool.comment ).split( ":" );
        
        for ( var n in comment_items )
            if ( /gang/i.test( comment_items[ n ] ) ) {
                this.toolOnGangPlate = true;
                break;
            }
    }
 

    this.toolType = tool.getType( );
    this.toolDiam = tool.getDiameter( );
    this.feedMode = section.feedMode === FEED_PER_REVOLUTION ? 95 : 94;
    this.spindleMode = tool.getSpindleMode( );
    this.surfaceSpeed = tool.surfaceSpeed * ( ( unit === MM ) ? 1/1000.0 : 1/12.0 );
    this.rpm = tool.spindleRPM;
    
    var toolDescript = this.toolNum === this.c_barPullerToolNum ? " Stock Transfer" : " " + tool.vendor + " " + tool.description ;
    this.toolingComment = "-- tool: " + this.toolNum + toolDescript;
    this.toolLine = this.toolNum + " " + tool.vendor + " " + tool.description + " " + tool.comment;
    this.compOffset = tool.isTurningTool( ) ? tool.compensationOffset : tool.lengthOffset;
    this.toolLength = tool.bodyLength;
    if ( prevSection !== undefined )
        this.toolIsNewTool = prevSection.getTool( ).number !== this.toolNum; 
    
    // check tool metrics - issue warnings
    switch ( this.toolType ) {
        case TOOL_TAP_RIGHT_HAND:
        case TOOL_TAP_LEFT_HAND:
            if ( tool.threadPitch  > this.toolDiam / 3 )
                warnings.pushWarning( " Tool: " + this.toolNum + " - pitch it too large" );
            if ( this.toolType === TOOL_TAP_LEFT_HAND  && tool.isClockwise( ) )
                warnings.pushWarning( " Tool: " + this.toolNum + " M3 on left hand tap" );
            if ( this.toolType === TOOL_TAP_RIGHT_HAND  && ! tool.isClockwise( ) )
                warnings.pushWarning( " Tool: " + this.toolNum + " M4 on right hand tap" );
            break;
        case TOOL_TURNING_BORING:
            if ( section.getFinalPosition( ).z < section.getInitialPosition( ).z )
                warnings.pushWarning( " Tool: " + this.toolNum + " may retract through part" );
//            if ( section.getFinalPosition( ).z < section.getInitialPosition( ).z )
//                warnings.pushWarning( " Tool: " + this.toolNum + " may retract through part" );
            break;
        case TOOL_DRILL:
            if ( ! tool.isClockwise( ) )
                warnings.pushWarning( " Tool: " + this.toolNum + " M4 detected on drill" );
            break;
        case TOOL_DRILL_CENTER:
            if ( ! tool.isClockwise( ) )
                warnings.pushWarning( " Tool: " + this.toolNum + " M4 detected on center drill" );
            break;
        case TOOL_DRILL_SPOT:
            if ( ! tool.isClockwise( ) )
                warnings.pushWarning( " Tool: " + this.toolNum + " M4 detected on spot drill" );
            break;
        default:
            if ( ! tool.isClockwise( ) )
                warnings.pushWarning( " Tool: " + this.toolNum + " M4 detected on this tool" );
            break;
    }
    

    this.writeToolHeader = function( section ) {
        if ( properties.writeToolingInfo )  {
            writeComment("==============================================================");
            writeComment( "Tool: " + this.toolLine );
            writeComment( "Time: " + formatCycleTime( _getToolCT( getCurrentSectionId( ) ) ) );
            writeComment( "   Z: " + zFormat.format( _getToolZ( getCurrentSectionId( ) ) ) );
        }
        else
            writeComment( "Tool: " + this.toolLine );
            
        if ( section.hasParameter( "operation-comment" ) )
            writeComment( "  Op: " + section.getParameter( "operation-comment" ) );
    };
    
    this.writeOpHeader = function( section ) {
        var comment = section.hasParameter( "operation-comment" ) ? section.getParameter( "operation-comment" ) : undefined;
        
        if ( properties.writeToolingInfo )  {
            writeComment("..   ..   ..   ..   ..   ..   ..   ..   ..   ..   ..   ..   ..");
            if ( comment !== undefined )  {
                writeComment( "  Op: " + comment);
                writeComment( "Time: " + formatCycleTime( currentSection.getCycleTime( ) ) );
                writeComment( "   Z: " + zFormat.format( currentSection.getGlobalZRange( ).getMinimum( ) ) );
            } 
        }
        else if ( comment !== undefined )
            writeComment( "  Op: " + comment);
    };

    this.writeToolCallCmd = function( section ) {
        if ( this.toolNum > this.maxToolNum )
            warning(localize("Tool number exceeds maximum value."));
        var compensationOffset = isStockTranferOp( section ) ? this.c_barPullerToolNum : this.compOffset;
        
        if ( compensationOffset > this.maxToolNum ) {
            error( localize( "Compensation offset is out of range." ) );
            return false;
        }
        writeBlock("T" + toolFormat.format( this.toolNum * 100 + compensationOffset ) );
        return true;
    };
    
    this.writeHeader = function ( ) {
        if ( this.toolIsNewTool )
            this.writeToolHeader( currentSection );
        else
            this.writeOpHeader( currentSection );
    };
    
    this.isGang = function( ) { return this.toolCuttingDir === toolType.GANG; };
    this.valid = function( ) { return this.toolNum !== 0 && this.sectionName !== "" && this.sectionName.length > 0; };
    this.matchName = function ( name ) { return this.sectionMatchName.search( name ) >= 0; };
    this.setLastTool = function( ) { this.isLastTool = true; };
    this.set30Type = function( ) { this.tool30Type = tool30Type.ZONLY; };
//  debugOut( " ToolInfo: sectionId: " + this.sectionId + " toolNum: " + this.toolNum );
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate an array of toolRecord objects above, plus info about the set
// of tooling as a whole
function toolingInfo( warnings ) {
    this.tooling = [ ];
    this.xPlusCount = 0;
    this.xMinusCount = 0;
    this.gangCount = 0;
    this.adjacentGangToolingCount = 0;
    this.maxGangToolSafeZ = properties.gangToolSafeMargin;
    this.maxTurretToolZ = properties.gangToolSafeMargin;
    this.maxQCTPToolZ = properties.gangToolSafeMargin;
    this.approxG30RoundTrips = 0;
    this.manualToolChangTime = 0;
    this.gangIndexTime = 0;
    this.promptString = "";
    this.totalToolChangeTime = 0;
    this.initalized = false;
    this.tool0_state = true;
    this.isPureGangToolMode = false;
    
    var numberOfSections = getNumberOfSections( );
    var numberOfTools = 0;
    var adjacentXPlusTooling = 0;
    var lastToolType = toolType.NOTYPE;
    var lastGangToolLen = 0;
    var maxDeltaLengthOnGang = 0;
    var lastToolNum = -1;
    var trLast = undefined;
    
    for (var i = 0; i < numberOfSections; ++i ) {
        var tr = new toolRecord( i, warnings );
        var section = getSection( i );
        
        if ( tr.toolNum !== lastToolNum ) {
            var holderHeadLength = section.hasParameter( "operation:tool_holderHeadLength" ) ? section.getParameter( "operation:tool_holderHeadLength" ) : 1;
            
            // #HACK
            holderHeadLength = holderHeadLength > 5.5 ? holderHeadLength / 25.4 : holderHeadLength; // adjust for metric value
            if ( tr.toolOnGangPlate )  {
                // Toggle and lock the state of this.adjacentGangTooling
                // if there are two adjacent gang ops using different tools
                ++this.gangCount;
                if ( lastToolType === toolType.GANG ) {
                    ++this.adjacentGangToolingCount;
                    maxDeltaLengthOnGang = Math.max( maxDeltaLengthOnGang, Math.abs( lastGangToolLen - tr.toolLength ) );
                    this.maxGangToolSafeZ = Math.max( this.maxGangToolSafeZ, maxDeltaLengthOnGang );
                    trLast.set30Type( );
                }
                lastToolType = toolType.GANG;
                lastGangToolLen = tr.toolLength;

            }
            if ( tr.toolCuttingDir === toolType.XMINUS ) {
                ++this.xMinusCount;
                if ( tr.toolOnGangPlate === false )  {
                    lastToolType = toolType.XMINUS;
                    this.maxQCTPToolZ = Math.max( this.maxQCTPToolZ, tr.toolLength !== 0 ? tr.toolLength : holderHeadLength );
                }
            }
            else if ( tr.toolCuttingDir === toolType.XPLUS )  {
                ++this.xPlusCount;
                if ( lastToolType === toolType.XPLUS )
                    ++adjacentXPlusTooling;
                if ( tr.toolOnGangPlate === false )  {
                    lastToolType = toolType.XPLUS;
                    this.maxTurretToolZ = Math.max( this.maxTurretToolZ, tr.toolLength !== 0 ? tr.toolLength : holderHeadLength );
                }
            }
            lastToolNum = tr.toolNum;
            ++numberOfTools;
        }
        this.tooling.push( tr );
        if ( i === numberOfSections - 1 )
            tr.setLastTool( );
        trLast = tr;
        
    }
    this.initalized = true;
    if ( this.adjacentGangToolingCount > 0 && properties.using_GangTooling )  {
        this.promptString = "   **** PUT LATHE INTO GANG TOOL MODE ***";
        if ( this.xMinusCount <=1 && this.xPlusCount <= 1 )
            this.isPureGangToolMode = true;
    }
    else if ( this.xMinusCount > 0 && this.xPlusCount === 0 )
        this.promptString = "   **** PUT LATHE INTO QCTP MODE ***";
    else if ( this.xMinusCount <= 1 && this.xPlusCount > 0 )
        this.promptString = "   **** PUT LATHE INTO TURRET MODE ***";
    else if ( this.xMinusCount > 0 && this.xPlusCount > 0 )
        this.promptString = "   **** PUT LATHE INTO TURRET MODE ***";
//  debugOut( " toolingInfo: xMinusCount: " + this.xMinusCount + " xPlusCount: " + this.xPlusCount + " gangCount: " +  this.gangCount );
    
    // attemp to calulate the total tool change time...
    var factor = unit === MM ? 25.4 : 1;
    var _rapid = properties.rapidFeed * factor;
    var normalG30Count = properties.using_GangTooling === true ? numberOfTools - this.adjacentGangToolingCount : numberOfTools;

    if ( properties.using_GangTooling === true )
        this.totalToolChangeTime = this.adjacentGangToolingCount * ( this.maxGangToolSafeZ + properties.gangToolSafeMargin ) / _rapid * 60;
    this.totalToolChangeTime += normalG30Count * ( this.maxTurretToolZ + properties.gangToolSafeMargin ) / _rapid * 60;
    this.totalToolChangeTime += adjacentXPlusTooling * 2; // two seconds to change turret tool.
    this.totalToolChangeTime += this.xMinusCount * properties.manualToolChangeTime; // two seconds to change turret tool.
    
    this.getLatheModePrompt = function( ) { return this.promptString; };
    this.usesGangOptimization = function( ) { return this.adjacentGangTooling > 0; };
    this.hasXMinusTools = function( ) { return this.xMinusCount > 0; };
    this.recommendedGangZ = function( ) { return this.maxGangToolSafeZ + properties.gangToolSafeMargin; };
    this.getToolChangeTime = function( ) { return this.totalToolChangeTime; };
    this.isTool0 = function( ) { var ret = this.tool0_state; this.tool0_state = false; return ret; };

    this.getToolInfo = function( sectionId ) {
        if ( sectionId === undefined )
            sectionId = getCurrentSectionId( );
        if ( sectionId >= 0 || sectionId < getNumberOfSections( ) )
            return this.tooling[ sectionId ];
        error( " getToolInfo: sectionId not valid " + sectionId );
        return undefined;
    };

    this.getTN = function( section ) {
        if ( section === undefined )
            section = getSection( getCurrentSectionId( ) );
        var toolRecord =  this.tooling[ section.getId( ) ];
    //  debugOut( " getTN: section.getId( ): " + section.getId( ) + " toolNum Found: " + toolRecord.toolNum );
        if ( toolRecord.valid( ) )  
            return toolRecord.toolNum;
        error( " getTN: toolRecord not valid " );
        return 0;
    };

    this.findToolFromSectionName = function( name ) {
        for ( var n in  this.tooling ) {
            if (  this.tooling[ n ].matchName( name ) )
                return  this.tooling[ n ];
        }
        return undefined;
    };
    
    this.writeG30 = function( loopStack ) {
        var isTool0 = this.isTool0( );
        var tr = this.getToolInfo( );
        
        if (  properties.using_GangTooling )  {
            if ( tr.tool30Type === tool30Type.ZONLY && !isTool0 ) {
                writeln("");
                writeComment("...pull back to safe Z...");
                writeBlock( zOutput.format( this.recommendedGangZ( ) ) );
            }
            else {
                writeln("");
                writeBlock( gFormat.format(30) );
                if ( ! this.isPureGangToolMode && ! tr.isLastTool )
                    writeBlock( mFormat.format(0) );
                else if ( ! this.isPureGangToolMode && tr.isLastTool && loopStack.isOpen( ) )
                    writeBlock( mFormat.format(0) );
            }
        }
        else {
            writeln("");          
            properties.tormachMillLathing ? writeBlock( gFormat.format(30) ) : writeBlock( gFormat.format(30), "Z #5422" );
        }
    };

    this.getToolChangeTime = function( ) { return this.totalToolChangeTime; };
    
}
//--------------------------------------------------------------------------------------------------------------
// encapsulate the retract state
function retract( ) {
    this.retractState = false;
    this.isRetracted = function( ) { return this.retractState; };
    this.onMove = function( ) { this.retractState = false; };
    this.doRetract = function( tooling, loopStack ) {
        if ( this.retractState === false )
            tooling.writeG30( loopStack );
        this.retractState = true;
    };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate the coolant state
function coolant( ) {
    this.coolantMode = COOLANT_OFF;
    this.coolantOnFirstZ = COOLANT_OFF;

    this.zStateOff = function( ) { this.coolantOnFirstZ = 0; };
    this.getCoolantMode = function( ) { return this.coolantMode; };
    this.coolantOnZ = function( _z ) {
        var ret;
        if ( this.coolantOnFirstZ && _z ) {
            ret = mFormat.format( ( this.coolantOnFirstZ === COOLANT_FLOOD ) ? 8 : 88 );
            this.coolantOnFirstZ = 0;
        }
        return ret;
    };
    
    this.setCoolant = function( actions, coolant ) {
        if ( coolant === this.coolantMode )
            return; // coolant is already in same state

        var m = undefined;
        if ( coolant === COOLANT_OFF ) {
            var action = actions.findActionForCurrentSection( );

            if ( action === undefined || action.M9 === false ) 
                writeBlock(mFormat.format( ( this.coolantMode === COOLANT_THROUGH_TOOL ) ? 89 : 9 ) );
            this.coolantMode = COOLANT_OFF;
            return;
        }
        switch ( coolant ) {
            case COOLANT_FLOOD:
                this.coolantOnFirstZ = COOLANT_FLOOD;
                break;
            case COOLANT_THROUGH_TOOL:
                this.coolantOnFirstZ = COOLANT_THROUGH_TOOL;
                break;
            default:
                onUnsupportedCoolant( coolant );
                m = 9;
        }

        if ( m )
            writeBlock( mFormat.format( m ) );
        this.coolantMode = coolant;
    };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate the spindle state
function spindle( ) {
    this.spindleState = COMMAND_STOP_SPINDLE;
    this.spindleDir = 5;

    
    this.setSpindleDir = function( spindleDir ) { this.spindleDir = spindleDir; };
    this.setSpindle = function( newState ) { this.spindleState = newState; };
    this.setWriteSpindle = function( newState ) {
        if ( this.spindleState === newState )
            return;
        switch ( this.spindleState = newState ) {
            case COMMAND_SPINDLE_CLOCKWISE:  this.spindleDir = 3; break;
            case COMMAND_SPINDLE_COUNTERCLOCKWISE:  this.spindleDir = 4; break;
            case COMMAND_STOP_SPINDLE:
            default:   this.spindleDir = 5; break;
        }
        var m = mFormat.format( this.spindleDir );
        writeBlock( m );
    };
    this.writeSpindleCmd = function( section ) {
        var mSpindle = section.getTool( ).clockwise ? 3 : 4;
        var toolSpindleSpeed = 5000;
        var tool = section.getTool( );
        gSpindleModeModal.reset( );

        var spindleDir =  section.getTool( ).clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE;
        // The maxSpindleSpeed value propagates down from what's in the tool lib
        // The user can override this in the Tool setup tab, either way this parameter
        // is set.
        
        if ( properties.tormachMillLathing === true ) {
                writeBlock( sOutput.format( tool.spindleRPM /*Math.min( tool.spindleRPM, properties.maximumSpindleSpeed )*/ ),
                            mFormat.format( mSpindle ) );
                this.spindleState = spindleDir;
                return;
        }
        
        if ( section.hasParameter( "operation:tool_maximumSpindleSpeed" ) )
            toolSpindleSpeed = section.getParameter( "operation:tool_maximumSpindleSpeed" );

        if ( tool.getSpindleMode( ) == SPINDLE_CONSTANT_SURFACE_SPEED ) {
            // So currentSection.getMaximumSpindleSpeed() should propogate to the setup box or
            // "operation:tool_maximumSpindleSpeed"...
            var maximumSpindleSpeed = Math.min( toolSpindleSpeed, properties.maximumSpindleSpeed );

    //      debugOut( ";*** currentSection.getMaximumSpindleSpeed: " + currentSection.getMaximumSpindleSpeed( ),
    //                  ";*** tool.maximumSpindleSpeed: " + tool.maximumSpindleSpeed, 
    //                  ";*** properties.maximumSpindleSpeed: " +  properties.maximumSpindleSpeed );

            if ( tool.surfaceSpeed > 0 && maximumSpindleSpeed > 0 )  {
                writeBlock( gSpindleModeModal.format(96),
                            sOutput.format( section.getTool( ).surfaceSpeed * ( ( unit === MM ) ? 1/1000.0 : 1/12.0) ),
                            dOutput.format( maximumSpindleSpeed ),
                            mFormat.format( mSpindle ) );
                this.spindleState = spindleDir;
            }
        }
        else if ( tool.spindleRPM > 0 )  {
            writeBlock( gSpindleModeModal.format(97), sOutput.format( tool.spindleRPM ), mFormat.format( mSpindle ) );
            this.spindleState = spindleDir;
        }
    };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate the feed type state
function feedType( ) {
    this.ftState = 0;
    this.setFTyp = function( section ) { this.ftState = section.feedMode === FEED_PER_REVOLUTION ? 95 : 94; };
    this.getFTyp = function( ) { return this.ftState; };
    this.hasFTyp = function( ) { return this.ftState !== 0; };
    this.emitAndReset = function( reset, formatter ) {
        var ret = "";
        if ( this.ftState !==0 && reset === false ) {
            ret = formatter.format( this.ftState );
            this.ftState = 0;
        }
        return ret;
    };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate the optional;section state
function optionalState( ) {
    this.optionalSection = false;
    this.isOptionalState = function( ) { return this.optionalSection === true; };
    this.transitionToCurState = function( ) {
        var ret = this.optionalSection === true && ! currentSection.isOptional( );
        this.optionalSection = currentSection.isOptional( );
        return ret;
    };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate the optional;section state
function pendingRadiusComp( ) {
    this.pendingRadiusComp = -1;
    this.isPending = function( ) { return this.pendingRadiusComp >= 0; };
    this.setPendingRadiusComp = function( newState ) { this.pendingRadiusComp = newState; };
    this.reset = function( ) { this.pendingRadiusComp = -1; };
}


//--------------------------------------------------------------------------------------------------------------
// encapsulate sequence numbers
function lineNumber( ) {
    this.currLineNumber = properties.sequenceNumberStart;

    
    this.nextLineNumber = function( optional ) {
        if ( properties.showSequenceNumbers === false )
            return "";
        var ret = optional ? "/" : "";
        ret += nFormat.format( this.currLineNumber % 100000 );
        this.currLineNumber += properties.sequenceNumberIncrement;
        return ret;
    };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate program state
function programState( ) {
    this.pState = pState.OPENING;

    
    this.pStateIsPreSection = function( ) { return this.pState === pState.OPENING; };
    this.IsLastSection = function( ) { return this.pState === pState.LAST_SECTION; };
    this.setInSection = function( ) { this.pState = pState.IN_SECTIONS; };
    this.setLastSection = function( ) { this.pState = pState.LAST_SECTION; };
    this.setClosing = function( ) { this.pState = pState.CLOSING; };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate passthrough buffer
function passThroughBuffer( ) {
    this.ptBuffer = [ ];
    this.bPtr = 0;

    
    this.add = function( text ) { this.ptBuffer.push( text ); };
    this.empty = function( ) { return this.ptBuffer.length === 0; };
    this.next = function( ) { 
        if ( this.bPtr === this.ptBuffer.length )
            return undefined;
        var ret = this.ptBuffer[ this.bPtr ];
        ++this.bPtr;
        return ret;
    };
    this.dump = function( ) {
        if ( this.bPtr === this.ptBuffer.length )
            return undefined;
        writeln( "" );
        while ( this.bPtr < this.ptBuffer.length )
            writeln( this.ptBuffer[ this.bPtr++ ] );
    };
    this.reset = function( ) { this.bPtr = 0; };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate warnings .. may be expanded buffer
function warnings_( ) {
    this.warningBuffer = [ ];
    this.pushWarning = function( warningString ) {
        // check to see if warnings were instantiated.
        if ( warningString && warningString.length > 0 )
            this.warningBuffer.push( "  *** WARNING :" + warningString );
    };
    this.dump = function( ) {
        if ( properties.warnings === false )
            return;
        if ( this.warningBuffer.length > 0 )
            writeComment( " **** WARNINGS *************************************** ");
        for ( var n in this.warningBuffer )
            writeComment( this.warningBuffer[ n ] );
    };
}

//--------------------------------------------------------------------------------------------------------------
// encapsulate loop counting .. 
function loopStack_( ) {
    this.loopCount = 0;
    
    this.parsePassThrough = function( passthroughStr ) {
        if ( String( passthroughStr ).match( new RegExp( /o[0-9]+\srepeat/i ) ) )
            ++this.loopCount;
        else if ( String( passthroughStr ).match( new RegExp( /o[0-9]+\sendrepeat/i ) ) ) 
            --this.loopCount;
    };
    
    this.isOpen = function( ) { return this.loopCount > 0; } ;
}


// inial program info
var g_fileGenerated;

//collected state
var g_sectionCount = 0;
var g_sequenceNumber;
var g_currentWorkOffset;
var g_optionalState;
var g_pendingRadiusComp;
var g_passThroughBuffer;
var g_fTyp; // state variable to control G93-G95
var g_pState;
var g_retract;
var g_coolant;
var g_spindle;
var g_tooling;
var g_warnings;
var g_loopStack;
var g_actions;

//==================================================================================================
// action stuff

// check to see if this is a bar pulling op
function isStockTranferOp( section ) {
    if ( section === undefined )
        section = currentSection;
    if ( ! section )
        return false;
    return  section.getTool( ).number === 0 &&
            section.hasParameter( "operation-strategy" ) && 
            section.getParameter( "operation-strategy" ) === "turningStockTransfer";
}

//==================================================================================================
// Tool Info stuff

// attemps to get a minimum X value for 
// internal operations...
function _getToolX( sectionId ) {
    if ( sectionId === undefined )
        sectionId = getCurrentSectionId( );
    var ti = g_tooling.getToolInfo( sectionId );
    var numberOfSections = getNumberOfSections( );
    var baseNumber = 100000;
    var xSide = ti.valid( ) ?  ti.toolCuttingDir === toolType.XMINUS ? -1 : ti.toolCuttingDir === toolType.XPLUS ? 1 : 0 : 0;
    var xRet = baseNumber;

    for( ; sectionId  < numberOfSections; ++sectionId ) {
        var section = getSection( sectionId );
        
        if ( g_tooling.getTN( section ) !== ti.toolNum )
            break;
        var action = g_actions.findActionRec( section.getParameter( "operation-comment" ) );
        
        if ( action !== undefined && action.modifier === "suppress" )  {
            xRet = action.minX;
            continue;
        }
        else if ( section.hasParameter( "operation-strategy" ) && section.getParameter( "operation-strategy" ) === "turningThread" ) {
            if ( section.hasParameter( "operation:turningMode" ) && section.getParameter( "operation:turningMode" ) === "inner" ) {
                xRet = Math.abs( section.getGlobalBoundingBox( ).lower.x ) * xSide;
            }
        }
        else if ( section.hasParameter( "operation:turningMode" ) && section.getParameter( "operation:turningMode" ) === "inner" ) {
            xRet = Math.min( Math.abs( xRet ), Math.abs( section.getGlobalBoundingBox( ).lower.x ) );
            xRet *= xSide;
        }
    }
//  debugOut( "_getToolX: xRet: " + xRet );
    return Math.abs( xRet ) === baseNumber ? 0 : xRet;
}


// does a look ahead to get the the cycle time for
// the current tool
function _getToolZ( sectionId ) {
   if ( sectionId === undefined )
        sectionId = getCurrentSectionId( );
    var toolNum = g_tooling.getTN( getSection( sectionId ) );
    var numberOfSections = getNumberOfSections( );
    var zRet = Infinity;

    for( ; sectionId  < numberOfSections; ++sectionId ) {
        var section = getSection( sectionId );
        
        if ( g_tooling.getTN( section ) !== toolNum )
            break;
            
        var sectionZ = section.getGlobalZRange( ).getMinimum( );
        var action = g_actions.findActionRec( section.getParameter( "operation-comment" ) );
        
        if ( action !== undefined )  {
            if ( action.modifier === "suppress" )
                sectionZ = action.maxZ;
            else
                sectionZ = Math.min( sectionZ, action.maxZ );
        }
        // special case for threading ..
        else if ( section.hasParameter( "operation-strategy" ) && section.getParameter( "operation-strategy" ) === "turningThread" ) {
            var incZ = section.hasParameter( "incrementalZ" ) ? section.getParameter( "incrementalZ" ) : 0;
            var outer = section.hasParameter( "operation:turningMode" ) && section.getParameter( "operation:turningMode" ) === "outer";
            var startZ = section.getBoundingBox( ).upper.z;
            var sectionMetric = section.hasParameter( "operation:metric" ) && section.getParameter( "operation:metric" ) > 0;
//          debugOut( "_getToolZ: section.getParameter( \"incrementalZ\" ) "  + incZ );
            
            incZ = ( sectionMetric === false  && Math.abs( incZ ) > 5 ) ? incZ / 25.4 : incZ;  // HACK: to get this in proper units.
            sectionZ = incZ !== 0 ? incZ + startZ : 0;
//          debugOut( "_getToolZ: ( unit !== MM && incZ > 5 ) "  + incZ );
//          debugOut( "_getToolZ: section.section.getBoundingBox( ).upper.z "  + startZ );
         }

        zRet = Math.min( zRet, sectionZ );
    }
    return zRet === Infinity ? 0 : zRet;
}

// does a look ahead to get the the cycle time for
// the current tool
function _getToolCT( sectionId ) {
    if ( sectionId === undefined )
        sectionId = getCurrentSectionId( );
    var toolNum = g_tooling.getTN( getSection( sectionId ) );
    var numberOfSections = getNumberOfSections( );
    var rapidIPM = properties.rapidFeed ? properties.rapidFeed : 60;
    var ctRet = 0;
    var factor = unit === MM ? 25.4 : 1;

    for( ; sectionId  < numberOfSections; ++sectionId ) {
        var section = getSection( sectionId );
        
        if ( g_tooling.getTN( section ) !== toolNum )
            break;
            
        var sectionCt = section.getCycleTime( );
        var action = g_actions.findActionRec( section.getParameter( "operation-comment" ) );
        
        sectionCt += section.getRapidDistance( ) / ( rapidIPM * factor * 60 );
        if ( action !== undefined )  {
            sectionCt += action.ct;
            if ( action.modifier === "suppress" )
                sectionCt = action.ct;
        }
        ctRet += sectionCt;
    }
    return ctRet;
}


//==================================================================================================
// setup X for diameter QCTP
function _getTrueX( _x ) {
    var ti = g_tooling.getToolInfo(  getCurrentSectionId( ) );
    
    if ( ti.toolCuttingDir == toolType.XPLUS )
        return _x;
    
    if ( g_tooling.hasXMinusTools( ) || properties.using_GangTooling )
        _x = -_x;
    
    return _x;
}

function writeX(_x) {
    return properties.tormachMillLathing ? xrOutput.format( _getTrueX( _x ) ) : xOutput.format( _getTrueX( _x ) );
}
/**
Writes the specified block.
*/
function writeBlock( ) { writeWords2( g_sequenceNumber.nextLineNumber( ), arguments); }

function formatComment( text ) {
    if ( text === undefined )
        return ";";
    return ";" + " " + text;
}

/**
Output a comment.
*/
function writeComment( text ) {
    writeln( formatComment( text ) );
}
// formats cycle time
function formatCycleTime( ct ) {
    var d = new Date(1899, 11, 31, 0, 0, ct + 0.5, 0);
    return  timeFormat.format( d.getHours( ) ) + ":" + 
            timeFormat.format( d.getMinutes( ) ) + ":" +
            timeFormat.format( d.getSeconds( ) );
}

function onParameter( ) {
    // these come after 'onOpen' ...
    if (typeof( arguments[ 0 ] ) === 'string' && arguments[ 0 ] === "document-path" )
        writeComment( "       Document: " + arguments[ 1 ] );
    else if (typeof( arguments[ 0 ] ) === 'string' && arguments[ 0 ] === "generated-by" )
        writeComment( "            CAM: " + arguments[ 1 ] );
    else if (typeof( arguments[ 0 ] ) === 'string' && arguments[ 0 ] === "generated-at" )
        g_fileGenerated = " ***LOCKED***  : " + arguments[ 1 ];
    // come before first section...
    else if (typeof( arguments[ 0 ] ) === 'string' && arguments[ 0 ] === "action" )
        g_actions.stowAction( arguments[ 1 ] );
}

function onOpen( ) {
    // this must go first...
    g_warnings = new warnings_( );
    g_tooling = new toolingInfo( g_warnings );
    // then this can go...
    g_fTyp = new feedType( );
    g_pState = new programState( );
    g_optionalState = new optionalState( );
    g_pendingRadiusComp = new pendingRadiusComp( );
    g_passThroughBuffer = new passThroughBuffer( );
    g_retract = new retract( );
    g_coolant= new coolant( );
    g_spindle = new spindle( );
    g_actions = new actionsInfo( g_tooling, g_warnings );
    g_sequenceNumber = new lineNumber( );
    g_loopStack = new loopStack_( );
    
    if ( !properties.separateWordsWithSpace )
        setWordSeparator( "" );

    writeProgramStart( );

}

function onComment( message ) {
    writeComment( message );
}

/** Force output of X, and Z. */
function forceXZ() {
    xOutput.reset();
    zOutput.reset();
}

/** Force output of X, Z, and F on next output. */
function forceAny() {
    forceXZ();
    feedOutput.reset();
}

function getSpindle() {
    return SPINDLE_PRIMARY;
}

// formats the tool line in the header to display min Z and CycleTime
function _entryFixup( entry, minZ, minX, ct, maxComment ) {
    var zCol = maxComment + 3;
    var xCol = zCol + 15;
    var ctCol = xCol + 15;
    
    for( var i = entry.length; i < zCol; ++i )
        entry += " ";
    entry += "Z : " +  zFormat.format( minZ );
    for( var i = entry.length; i < xCol; ++i )
        entry += " ";
    if ( minX != 0 )
        entry += "X : " +  xFormat.format( minX );
    for( var i = entry.length; i < ctCol; ++i )
        entry += " ";
    return entry +=  "CT: " + formatCycleTime( ct );
}

function writeProgramStart( ) {
    if ( programName ) {
        writeComment( "  program:   " + programName );
        if ( programComment )
            writeComment( "             " + programComment );
        writeComment( );
    }    
}
// Returns the tool information in an array.
function writeInitMachineState( ) {
    if ( properties.tormachMillLathing == false )
        writeBlock( gFormat.format(7) );
    writeBlock( gPlaneModal.format(18) );
    switch ( unit ) {
        case IN:
            writeBlock( gUnitModal.format( 20 ) );
            break;
        case MM:
            writeBlock( gUnitModal.format( 21 ) );
            break;
    }
    writeBlock( gFormat.format(54) );
    writeBlock( gFormat.format(40 ));
    writeBlock( gAbsIncModal.format(90) );
}

function writeToolInfo( ) {
    
    if ( properties.writeToolingInfo === false )
        return;
        
    var result = [ ];
    var lastToolIndex = 0;
    var minimumZ;
    var tn_ = -1;
    var numberOfSections = getNumberOfSections();
    var maxComment = 0;
    var totalCT = 0;
   
    // preload all the 'action' commands


    for ( var i = 0; i < numberOfSections; ++i ) {
        var section = getSection( i );
        var secTn = g_tooling.getTN( section );
        if ( secTn !== tn_) {
            maxComment = Math.max( g_tooling.getToolInfo( i ).toolingComment.length, maxComment );
            tn_ = secTn;
        }
    }

    tn_= 0;
    var lastToolSectionId = -1;
    var ct = 0;
    var toolDescription = "";

    for ( var i = 0; i < numberOfSections; ++i ) {
        var section = getSection( i );
        var currTN = g_tooling.getTN( section );

        // the next tool is up...
        if ( currTN !== tn_) {
            // fix up the last tool entry...on the first iteration tn_ will be 0
            if ( tn_ > 0 )  {
                totalCT += ( ct = _getToolCT( lastToolSectionId ) );
                result[ lastToolIndex ] = _entryFixup( result[ lastToolIndex ],
                                                        _getToolZ( lastToolSectionId ),
                                                        _getToolX( lastToolSectionId ),
                                                        ct ,
                                                        maxComment );
            }
            tn_ = currTN;
            lastToolIndex = result.length;
            lastToolSectionId = i;
            result.push( g_tooling.getToolInfo( i ).toolingComment );
        } // currTN != tn_
        result.push( new String( "          op: " +  section.getParameter( "operation-comment" ) ) );
    } // for
    totalCT += ( ct = _getToolCT( lastToolSectionId ) );
    if ( result.length > 0 )
        result[ lastToolIndex ] = _entryFixup( result[ lastToolIndex ],
                                                _getToolZ( lastToolSectionId ),
                                                _getToolX( lastToolSectionId ),
                                                ct,
                                                maxComment );
    

    // warning to put lathe into right mode...
    writeComment( );
    if ( properties.tormachMillLathing === false )  {
        writeComment( g_tooling.getLatheModePrompt( ) );
        writeComment( );
    }
    var totalPartTime = totalCT + g_tooling.getToolChangeTime( ) + properties.partLoadTime;
    
    writeComment("Tool / Op list ..............................................................................");
    for ( var i in result )
        writeComment( result[ i ] );
    writeComment( );
    writeComment( "Approximate tool change time:  ................  :  " + formatCycleTime( g_tooling.getToolChangeTime( ) ) );
    writeComment( "Approximate part load time:  ..................  :  " + formatCycleTime( properties.partLoadTime ) );
    writeComment( "total cycle time ( with approx tool change time ):  " + formatCycleTime( totalPartTime )  + "   (" + secFormat.format( totalPartTime / 3600 ) + " hrs. )" );
    writeComment( );
}

function writeInitialHeaderInfo( ) {
    
    writeComment( " Post Processor: " + g_description );
//  writeComment( "       Material: " + getParameter( "inventor:Material" ) );
    writeComment( );
    writeComment( g_fileGenerated );
    writeComment( );
    writeComment( );
}

function writeSectionNotes( section ) {
    if ( properties.showNotes && section.hasParameter( "notes" ) ) {
        var notes = section.getParameter( "notes" );
        if ( notes ) {
            var lines = String(notes).split( "\n" );
            for ( var line in lines) {
                var comment = lines[line].replace( new RegExp( /^[\\s]+/g ), "" ).replace( new RegExp( /[\\s]+$/g ), "");
                if ( comment ) {
                    if ( line === 0 )
                        writeComment( "Note: " + comment );
                    else
                        writeComment( "      " + comment );
                }
            }
        }
    }
}

function abortOnSectionTypeError( ) {
    if ( currentSection.getType( ) === TYPE_TURNING )
        return false;
    if ( hasParameter( "operation-strategy" ) && getParameter( "operation-strategy" ) === "drill" )
        return false;
    if ( currentSection.getType( ) === TYPE_MILLING )
        error( localize( "Milling toolpath is not supported." ) );
    else
        error( localize( "Non-turning toolpath is not supported." ) );
    return true;
}

function onSection( ) {
    // needs to be done here because all the external file 'action' stuff
    // is gotten between onOpen and onSection
    if ( isFirstSection( ) ) {
        writeInitialHeaderInfo( );
        writeToolInfo( );
        g_warnings.dump( );
        writeInitMachineState( );
        writeParkTool( );
        g_passThroughBuffer.dump( );
    }
    g_pState.setInSection( );
    if ( isLastSection( ) )
        g_pState.setLastSection( );
    if ( abortOnSectionTypeError( ) )
        return;

    var forceToolAndRetract = g_optionalState.transitionToCurState( );
    var toolInf = g_tooling.getToolInfo( );
    var sectionHasToolChange = forceToolAndRetract ||
                         isFirstSection( )    ||
                         ( currentSection.getForceToolChange && currentSection.getForceToolChange( ) ) ||
                         ( toolInf.toolNum !== g_tooling.getTN( getPreviousSection( ) ) ); // for some very wierd reason this doesn't work ???
    var newWorkOffset = isFirstSection( ) || ( getPreviousSection( ).workOffset !== currentSection.workOffset ); // work offset changes

    if ( sectionHasToolChange || newWorkOffset )
        forceXZ( );

    writeln( "" );
    toolInf.writeHeader( );
    writeSectionNotes( currentSection );

    if ( sectionHasToolChange && ! toolInf.writeToolCallCmd( currentSection ) )
        return;
    if ( g_actions.actionIsPrepend( ) )
        g_actions.postActionData( );


    //set coolant after we have positioned at Z
    g_coolant.setCoolant( g_actions, tool.coolant );

    forceAny( );
    gMotionModal.reset( );
    gFeedModeModal.reset( );
    g_fTyp.setFTyp( currentSection );

    g_spindle.writeSpindleCmd( currentSection );
    setRotation( currentSection.workPlane );

    var actionModifier = g_actions.getActionModifier( );
    var initialPosition = getFramePosition(currentSection.getInitialPosition( ));
    if ( ! g_retract.isRetracted( ) && actionModifier !== "suppress" ) {
        //TAG: need to retract along X or Z
        if ( getCurrentPosition( ).z < initialPosition.z) {
            writeBlock( gMotionModal.format( 0 ), zOutput.format( initialPosition.z ) );
//            g_retract.onMove( ); I think this is wrong, it's not in the G30 state.
        }
    }

    if ( sectionHasToolChange ) {
        gMotionModal.reset( );
        if ( actionModifier !== "suppress" ) {
            var m = g_coolant.coolantOnZ( initialPosition.z );
            var upperZ = 0;
            
            if ( hasParameter( "stock-upper-z" ) )
                upperZ = getParameter( "stock-upper-z" );

            // TODO: Force X move before Z. revisit this logic to handle transition fomr X+ to X- tooling
            if ( ! isStockTranferOp( ) && 
                ( toolInf.isGang( ) || properties.forceX_first_onFirstMove || initialPosition.z <= upperZ ) ) {
                writeBlock( gMotionModal.format(0), writeX(initialPosition.x) );
                writeBlock( zOutput.format(initialPosition.z), m );
                g_retract.onMove( );
            }
            else if ( ! isStockTranferOp( ) )  {
                writeBlock( gMotionModal.format(0), 
                            writeX(initialPosition.x),
                            zOutput.format(initialPosition.z), m );
                g_retract.onMove( );
            }
            gMotionModal.reset( );
        }
        else  { // actionModifier == "suppress"
            g_actions.insertActionCoolant( g_coolant.getCoolantMode( ) );
            g_coolant.zStateOff( );
        }
    }

    if ( sectionHasToolChange || g_retract.isRetracted( ) )
        gPlaneModal.reset();
    ++g_sectionCount;
}

function onDwell( seconds ) {
    if (seconds > 99.999)
        warning( localize("Dwelling time is out of range.") );
    writeBlock( gFormat.format( 4 ), "P" + dwellFormat.format( seconds ) );
}

function onRadiusCompensation( ) {  g_pendingRadiusComp.setPendingRadiusComp( radiusCompensation ); }

function onRapid(_x, _y, _z) {
    if ( g_actions.actionIsSuppress( ) )
        return;
    var x = writeX(_x);
    var z = zOutput.format(_z);
    var m = g_coolant.coolantOnZ( z );
        
    if (x || z) {
        if ( g_pendingRadiusComp.isPending( ) ) {
            g_pendingRadiusComp.reset( );
            switch ( radiusCompensation ) {
                case RADIUS_COMPENSATION_LEFT:
                    writeBlock(gMotionModal.format(0), gFormat.format(41), x, z, m);
                    break;
                case RADIUS_COMPENSATION_RIGHT:
                    writeBlock(gMotionModal.format(0), gFormat.format(42), x, z, m);
                    break;
                default:
                    writeBlock(gMotionModal.format(0), gFormat.format(40), x, z, m);
            }
        }
        else
            writeBlock(gMotionModal.format(0), x, z, m);
        g_retract.onMove( );
        feedOutput.reset();
    }
}

function onFirstFeed( _reset ) {
    if ( ! g_actions.actionIsSuppress( ) )
        return g_fTyp.emitAndReset( _reset, gFeedModeModal );
    return "";
}

function onLinear(_x, _y, _z, feed) {
    if ( g_actions.actionIsSuppress( ) )
        return;
    var x = writeX(_x);
    var z = zOutput.format(_z);
    var f = feedOutput.format( feed );
    var g = onFirstFeed( !( x || z ) && f && getNextRecord( ).isMotion( ) );

    if (x || z) {
        if ( g_pendingRadiusComp.isPending( ) ) {
            g_pendingRadiusComp.reset( );
            writeBlock(gPlaneModal.format(18));
            switch (radiusCompensation) {
                case RADIUS_COMPENSATION_LEFT:
                    writeBlock(g, gMotionModal.format(1), gFormat.format(41), x, z, f);
                    break;
                case RADIUS_COMPENSATION_RIGHT:
                    writeBlock(g, gMotionModal.format(1), gFormat.format(42), x, z, f);
                    break;
                default:
                    writeBlock(g, gMotionModal.format(1), gFormat.format(40), x, z, f);
            }
        }
        else
            writeBlock(g, gMotionModal.format(1), x, z, f);
        g_retract.onMove( );
    } else if (f) {
        if (getNextRecord().isMotion()) { // try not to output feed without motion
            feedOutput.reset(); // force feed on next line
        } else {
            writeBlock(g, gMotionModal.format(1), f);
        }
    }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
    if ( g_actions.actionIsSuppress( ) )
        return;
    var g = onFirstFeed( );
    
    if ( isSpeedFeedSynchronizationActive( ) ) {
        error(localize("Speed-feed synchronization is not supported for circular moves."));
        return;
    }

    if ( g_pendingRadiusComp.isPending( ) ) {
        error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
        return;
    }

    var start = getCurrentPosition( );

    switch (getCircularPlane()) {
        case PLANE_XY:
            error(localize("XY plane not allowed"));
            return;
        case PLANE_ZX:
//          debugOut( "; ***cx= " + cx, "; ***cz= " + cz, "; ***start.x= " + start.x, "; ***start.z= " + start.z );
            var inverted = g_tooling.getToolInfo( getCurrentSectionId( ) ).toolCuttingDir === toolType.XPLUS;
            var G2or3 = inverted ? clockwise ? 2 : 3 : clockwise ? 3 : 2;
            var iVal = inverted ? -( _getTrueX( start.x ) - _getTrueX( cx ) ) : _getTrueX( cx ) - _getTrueX( start.x );

            writeBlock( gMotionModal.format( G2or3 ),
                        writeX( x ),
                        zOutput.format(z),
                        iOutput.format( iVal, 0),
                        kOutput.format( ( cz - start.z ), 0),
                        feedOutput.format( feed ) );
            g_retract.onMove( );
            break;
        case PLANE_YZ:
            error(localize("YZ plane not allowed"));
            return;
        default:
            linearize(tolerance);
    }
}

function onCycle( ) {
    switch ( cycleType ) {
        case "stock-transfer" :
            if ( g_actions.actionIsPrepend( ) )
                g_actions.postActionData( );
            break;
   }
}

function getCommonCycle(x, y, z, r) {
    forceXZ( ); // force xyz on first drill hole of any cycle
    return [ writeX( x ), zOutput.format( z ),"R" + spatialFormat.format( r ) ];
}

function onCyclePoint(x, y, z) {

    if ( g_actions.actionIsSuppress( ) )
        return;
    switch ( cycleType ) {
        case "thread-turning":
            if ( ! isFirstCyclePoint( ) ) 
                return;
            
            g_retract.onMove( );
            var pos = currentSection.getFirstPosition( );
            if ( pos ) {
                writeBlock( writeX( pos.x ) );
                writeBlock( zOutput.format( pos.z ) );
            }

            var external = false;
            var inverted = getSection( getCurrentSectionId( ) ).getTool( ).turret > 0;
           
            // for HSM Inventor/Fusion
            if ( hasParameter( "operation:turningMode" ) )
                external = getParameter( "operation:turningMode" ) === "outer" ? true : false;
            // for HSMWorks
            else if ( hasParameter( "operation:top" ) ) {
                var tc = getParameter( "operation:top" );
                if ( Math.abs( tc ) < Math.abs( cycle.retract ) )
                    external = true;
            }
            
            
            var r = -cycle.incrementalX; // positive if taper goes down - delta radius
            var threadsPerInch = 1.0/cycle.pitch; // per mm for metric
            var p = 1/threadsPerInch;
            
            var driveLine = cycle.retract;  
            var threadCrest;
            if ( external ) {
                if ( hasParameter( "operation:outerRadius_value" ) )
                    threadCrest = getParameter("operation:outerRadius_value");
                else if ( hasParameter( "operation:top" ) )
                    threadCrest = getParameter( "operation:top" );
            }
            else {
                if ( hasParameter( "operation:innerRadius_value" ) )
                    threadCrest = getParameter("operation:innerRadius_value");
                else if ( hasParameter( "operation:top" ) )
                    threadCrest = getParameter( "operation:top" );
            }
            var threadDepth = getParameter("operation:threadDepth");
            var numPasses = getParameter("operation:numberOfStepdowns");
            var iVal = ( driveLine - threadCrest ) * 2;
            var rootLine = ( threadCrest - threadDepth ) * 2;
            var jVal = _calcThreadPasses( iVal,
                                         threadCrest * 2,
                                         rootLine,
                                         numPasses);
            var rVal = getParameter("operation:infeedMode") === "constant" ? 1 : 2;
            var qVal = getParameter("operation:infeedAngle");
            var hVal = getParameter("operation:nullPass");
            
//          debugOut( "p= " + p, "driveline= " + driveLine, "threadCrest= " + threadCrest, "threadDepth= " + threadDepth );            

            writeBlock( gMotionModal.format(76),
                        pOutput.format(p),
                        zOutput.format(z),
                        iThreadOutput.format( inverted ? -iVal : iVal ),
                        jThreadOutput.format( jVal ),
                        kThreadOutput.format( threadDepth ),
                        rThreadOutput.format( rVal ),
                        qThreadOutput.format( qVal ),
                        hVal > 0 ? hThreadOutput.format( hVal ) : "" );
            return;
        case "drilling":
        case "counter-boring":
        case "chip-breaking":
        case "deep-drilling":
        case "reaming":
            g_retract.onMove( );
            expandCyclePoint(x, y, z);
            return;
        case "tapping":
            var threadsPerInch = getParameter("operation:tool_threadPitch"); // per mm for metric
            writeBlock( gMotionModal.format(33.1),
                        zOutput.format(z),
                        kTapOutput.format( threadsPerInch ) );
            g_retract.onMove( );
            return;
    }
}

function onCycleEnd( ) {
    if ( ! cycleExpanded ) {
        switch ( cycleType ) {
            case "thread-turning":
                feedOutput.reset();
                xOutput.reset();
                zOutput.reset();
                break;
            case "drilling":
            case "counter-boring":
            case "chip-breaking":
            case "deep-drilling":
            case "reaming":
                writeBlock(gCycleModal.format(80));
                break;
            case "stock-transfer":
                break;
        }
    }
}

function onCommand(command) {
    switch (command) {
        case COMMAND_COOLANT_OFF:
            g_coolant.setCoolant( g_actions, COOLANT_OFF );
            return;
        case COMMAND_COOLANT_ON:
            g_coolant.setCoolant( g_actions, COOLANT_FLOOD );
            return;
        case COMMAND_STOP:
            writeBlock( mFormat.format( 0 ) );
            return;
        case COMMAND_OPTIONAL_STOP:
            writeBlock( mFormat.format( 1 ) );
            break;
        case COMMAND_END:
            writeBlock( mFormat.format( 2 ) );
            break;
        case COMMAND_STOP_SPINDLE:
            var action = g_actions.findActionForCurrentSection( );
        
            if ( action && action.M5 === true ) 
                g_spindle.setSpindle( command );
            // fall through...
        case COMMAND_SPINDLE_CLOCKWISE:
        case COMMAND_SPINDLE_COUNTERCLOCKWISE:
            g_spindle.setWriteSpindle( command );
            break;
        case COMMAND_START_SPINDLE:
            onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
            return;
        default:
//          onUnsupportedCommand(command);
    }
}

function writeParkTool( ) {        
    onCommand( COMMAND_COOLANT_OFF );
    onCommand( COMMAND_STOP_SPINDLE );
    g_retract.doRetract( g_tooling, g_loopStack );
}

function onSectionEnd( ) {
    if ( g_actions.actionIsSuppress( ) || g_actions.actionIsAppend( ) )
        g_actions.postActionData( );

    var parkTool = isLastSection( ) ||
                   ( g_optionalState.isOptionalState( ) && ! nextSection.isOptional( ) )    ||
                   ( currentSection.getForceToolChange && currentSection.getForceToolChange( ) ) ||
                   ( g_tooling.getTN( ) !== g_tooling.getTN( getNextSection( ) ) );

    if ( parkTool )
        writeParkTool( );
    forceAny( );
}

function onClose() {
    writeln("");
    g_pState.setClosing( );

    forceXZ( );
    writeParkTool( );
    onImpliedCommand(COMMAND_END);
    onImpliedCommand(COMMAND_STOP_SPINDLE);
    writeBlock( mFormat.format( 30 ) ); // stop program, spindle stop, coolant off
}

function _calcThreadPasses( toolClear, majDiam, minDiam, requestPasses ) {
    var depth = Math.abs( toolClear );
    var kNumber = Math.abs( majDiam - minDiam );
    var fullDiamDepth = depth;
    var endDepth= kNumber + fullDiamDepth;  
    var rMax = endDepth - depth;
    var rMin = rMax / requestPasses;
    var rMid = ( rMin + rMax ) / 2;
    
    for (var i = 1; i <= 100; ++i ) {
        var tPass_ = 0;
        var tDepth_ = depth;

        while ( tDepth_ < endDepth ) {
            tPass_ = tPass_ + 1;
            tDepth_ = fullDiamDepth + rMid * Math.sqrt( tPass_ );  // SQR( tPass_ ) = POW( tPass_, 1 /2 )
            if ( tPass_ >= 999 ) {
                break;
            }
        }

        if ( tPass_ === requestPasses ) {
            return rMid;
        } else if ( tPass_ > requestPasses ) {
            rMin = rMid;
            rMid = ( rMin + rMax ) / 2;
        } else {
            rMax = rMid;
            rMid = ( rMin + rMax ) / 2;
        }
    }
    return 0;
}

function onPassThrough( text ) {
    if ( String( text ).search( "file:" )  === 0 ) {
        var lines = [ ];
        var filenames = String( text ).split( ":" );

        _onGetLocalTextFile( properties.passThroughFilePath, filenames[ 1 ], lines );
        _postLocalTextFile( lines );
        writeParkTool( );
    }
    else  {
        var lines = String( text ).split( "|" );
        
        for ( var i in lines )  {
            var lineText = lines[ i ];
            
            g_loopStack.parsePassThrough( lineText );
            if ( g_pState.pStateIsPreSection( ) )
                g_passThroughBuffer.add( lineText );
            else {
                if ( g_pState.IsLastSection( ) )
                    writeln( "" );
                writeln( lineText );
            }
        }
    }
}

function _onGetLocalTextFile( path, fn, target ) {
    var filename = fn;
    var filepath = new String( path );
    var rawfile;
    var re = new RegExp( /(A-Za-z0-9_)\\(A-Za-z0-9_)/ );
    var pathDelim = String( filepath ).match( re ) ? "\\" : "/";
    
    if ( filepath.length === 0 )
        writeComment( " Error : no file or path" + filepath );
    else {
        if ( String( filepath ).charAt( filepath.length -1 ) !== pathDelim )
            filepath += pathDelim;
        if ( ! FileSystem.isFolder( filepath ) ) {
            writeln( "" );
            writeComment( "**error**error**error" );
            writeComment( " Error folder: "  + filepath + " not found ! ");
            writeComment( "**error**error**error" );  
            return "";
        }
        filepath += filename;
        if ( ! FileSystem.isFile( filepath ) ) {
            writeln( "" );
            writeComment( "**error**error**error" );
            writeComment( " Error file: "  + filepath + " not found ! ");
            writeComment( "**error**error**error" ); 
            return "";
        }
        
        try {
            var txt = loadText( filepath, "utf-8");
        
            if ( txt.length > 0 ) {
                var lines = String( txt ).split( "\r\n" );
                rawfile = lines.join( );
                
                for ( var i in lines ) 
                    target.push( new String( lines[ i ] ) );

            }
        }
        catch ( e ) {
            writeln( "" );
            writeComment( "**error**error**error" );
            writeComment( " Error can't load"  + filepath + " may not be text");
            writeComment( "**error**error**error" ); 
            return "";
        }
    }
    return rawfile;
}

function _postLocalTextFile( lines ) {
    if ( ! lines )
        return;
    var re = new RegExp( /([Gg][0-3]+)|([XxZz][-+]?[0-9]*\.?[0-9]+)/ );
    for ( var i in lines ) {
        if ( g_retract.isRetracted( ) && String( lines[ i ] ).match( re ) )
            g_retract.onMove( );
        writeln( lines[ i ] );
    }
}

function debugOut( ) {
    if ( ! properties.debugOutput )
        return;
    if ( arguments.length <= 1 )
        return;
    if ( typeof arguments[ 0 ] === 'boolean' && arguments[ 0 ] )
        for (var i = 1, j = arguments.length; i < j; ++i)
            writeln( "*debug: " + arguments[ i ] );
}
