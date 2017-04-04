delete cameras
$.pos = [0,0,0]
objDepth = ($.max.y-($.min.y))
Objwidth = ($.max.x-($.min.x))
if objDepth<=Objwidth then
(
	global pCamera = Objwidth*1.5
	global pCHeight = pCamera/2
	global ptop = pCamera
	global angleLength = pCamera * (cos 25)
	global angleHeigth = pCamera * (sin 25)
)
else
(
	global pCamera = objDepth*1.5
	global pCHeight = pCamera/2
	global ptop = pCamera
	global angleLength = pCamera * (cos 25)
	global angleHeigth = pCamera * (sin 25)
)
global positions = #([angleLength,0,angleHeigth],[-angleLength,0,angleHeigth],[0,angleLength,angleHeigth],[0,-angleLength,angleHeigth],[pCamera,0,0],[0,pCamera,0],[-pCamera,0,0],[0,-pCamera,0],[0,0,ptop],[0,0,-ptop],[pCamera,0,-pCHeight],[-pCamera,0,-pCHeight],[0,pCamera,-pCHeight],[0,-pCamera,-pCHeight])
global mainfoldername = $.name
makedir (@"C:\CSVFiles\" + (mainfoldername as string))
global mainfolderPath = (@"C:\CSVFiles\" + (mainfoldername as string))
global sizeObPlane = 10
renderHeight = sizeObPlane
renderWidth = sizeObPlane
while sizeObPlane <= 50 do
(
	makedir (mainfolderPath + "/" + (mainfoldername as string) + "_RES_" + (sizeObPlane as string))
	global Subfolder = (mainfolderPath + "/" + (mainfoldername as string) + "_RES_" + (sizeObPlane as string))
	for CAM=1 to 9 do
	(
		global NewCamera = targetcamera()
		newcamera.name = ("targetCamera_" + (CAM as string))
		newcamera.type = #free
		newcamera.type = #target
		newCamera.target.pos = [0,0,0]
		NewCamera.pos = positions[CAM]
	)
	--sizeObPlane = 50
	c=1
	for c=1 to cameras.count do
	(
		start = timestamp()
		if classof cameras[c] != Targetobject do
		(
			h =1
			global outputpath =  (Subfolder + @"\" + (mainfoldername as string) + "_" + (c as string) + "_Fullarray_" + (sizeObPlane as string) + "pixels"+ ".csv")
			--global outputpath =  @"C:\CSVFiles\rayDistanceTestView" + (c as string)+ ".csv"
			global outlineArrayOutput = (Subfolder + @"\" + (mainfoldername as string) + "_" + (c as string) + "_outline_" + (sizeObPlane as string) + "pixels"+ ".csv")
			--global outlineArrayOutput = @"C:\CSVFiles\outlineArrayOutput" + (c as string)+ ".csv"
			global r = ray [0,0,0] [0,0,1]
			global distanceofCamera = distance cameras[c] cameras[c].target
			global angleFOVTAN = tan (cameras[c].fov/2)
			global angleFOVTANSmall = tan ((cameras[c].fov)/2)
			global currentTarget = cameras[c].targetDistance = ptop*1.5
			global currentTargetPos = cameras[c].target.pos
			global ShortDistance = cameras[c].targetDistance = 0.01
			global ShortDistancePos = cameras[c].target.pos
			global cameraDir = cameras[c].dir
			cameras[c].targetDistance = currentTarget
			--t=1
			global obj = getcurrentselection()
			for o in obj do 
			(
				(
					(
						o.pivot = o.center
						global ObjectTop = (o.max.z)
						global xSize = (o.max.x)-(o.min.x)
						global ySize = (o.max.y)-(o.min.y)
						global zSize = (o.max.z)-(o.min.z) 
						if xsize <= ySize then
						(
							global squareSize = ySize
						)
						else
						(
							global squareSize = xSize
						)
					)
				)
			)
			convertTo obj[1] editable_poly
			global baseplane = plane()
			baseplane.name =  "particlebaseplane"	
			baseplane.width = (currentTarget * angleFOVTAN) *2
			baseplane.length = (currentTarget * angleFOVTANSmall) *2
			baseplane.widthsegs = sizeObPlane 
			baseplane.lengthsegs = sizeObPlane
			convertTo baseplane editable_poly
			global numofverts = polyop.getnumverts baseplane
			baseplane.pivot = baseplane.center
			baseplane.pos = currentTargetPos
			baseplane.dir = cameraDir
			global topPlane = plane()
			topPlane.name = "particleTopPlane"
			topPlane.width = (ShortDistance * angleFOVTAN) *2
			topPlane.length = (ShortDistance * angleFOVTANSmall) *2
			topPlane.lengthsegs = sizeObPlane
			topPlane.widthsegs = sizeObPlane 
			global lenghtsegments = topplane.lengthsegs
			global sideSegments = topplane.widthsegs
			topPlane.pivot = topplane.center
			topPlane.pos = ShortDistancePos
			topPlane.dir = cameraDir
			convertTo topPlane editable_poly
			fn rayCreationExport =
			(
				global outputpath2 =  createfile outputpath
				--global outlineArrayoutput2 = createfile outlineArrayOutput
				--arrayzCopy = copy arrayZ #nomap
				--formatedArray = #()
				global t=1
				for l=1 to (sizeObPlane +1) do
				(
					f = 1
					for w=1 to (sideSegments+1) do
					(
						global newTape = tape pos:(polyop.getvert topPlane t) target:(targetobject pos:(polyop.getvert baseplane (t)))
						originalTarget =distance newtape newtape.target
						global r = newtape as ray
						global arr = (intersectRay obj[1] r)
						if arr != undefined then
						(
							newtape.target.pos = arr.pos
							actualDistance = distance newtape newtape.target
							format "%" actualDistance to:outputpath2
							if f ==1 do
							(
								--format "%,%"f w to:outlineArrayoutput2
								f=2
							)
							if w!=(sideSegments+1) do
							(
								format "," to:outputpath2
							)
						)
						else 
						(
							format "0" to:outputpath2
							if w!=(sideSegments+1) do
							(
								format "," to:outputpath2
							)
						)
						delete newtape
						clearUndoBuffer()
						t+=1
					)
					format "\n" to:outputpath2
				)
				close outputpath2
				free outputpath2
			)
			fn outlineArray = 
			(
				fileExist = doesfileexist outputpath
				if fileExist == true do
				(
					--global outlineArrayOutput = (Subfolder + @"\" + (mainfoldername as string) + (c as string) + "_outline_" + (sizeObPlane as string) + "pixels"+ ".csv")
					outlineArrayoutput2 = createfile outlineArrayOutput
					csvFile = openfile outputpath
					invertedLastRow = #()
					firstRow = #()
					lineNow = 1
					firstRowValue = 0
					FirstRowLine = 0
					while eof csvFile != true do
					(
						linex = readline csvFile
						linestringArray = filterstring linex ","
						firstObjtestFount = false
						w=1
						while ((firstObjtestFount != true) and (w < linestringArray.count ))do
						(
							--local h = linestringArray[w]
							if linestringArray[w] !="0" then
							(
								if ((firstRowValue == 0) and (FirstRowLine == 0 )) do
								(
									firstRowValue = w
									FirstRowLine = lineNow
								)
								FirstRowDigits = (((w - firstRowValue) as string) + "," + ((linenow - FirstRowLine) as string))
								--print FirstRowDigits
								append  firstRow FirstRowDigits
								--print firstObjtestFount
								firstObjtestFount = true
							)
							w+=1
						)
						lineNow += 1
					)
					lineNow = 1
					close csvFile
					free csvfile
					csvFile = openfile outputpath
					while eof csvFile != true do
					(
						linex = readline csvFile
						linestringArray = filterstring linex ","
						lastRow = (linestringArray.count + 1)
						lastobjectTestFound = false
						w=1
						while ((lastobjectTestFound != true) and (w < lastRow)) do
						(
								--h = linestringArray[lastRow - w]
								if linestringArray[lastRow - w] !="0" then
								(
									lastRowDigits = ((((lastRow - w)-firstRowValue) as string) + "," + ((linenow - FirstRowLine) as string))
									--print lastRowDigits
									append  invertedLastRow lastRowDigits
									lastobjectTestFound = true
								)
								w+=1
						)
						lineNow += 1
					)
					lastRowCount = (invertedLastRow.count + 1)
					for d=1 to invertedLastRow.count do 
					(
						append  firstRow invertedLastRow[lastRowCount - d]
					) 
					for a=1 to firstRow.count do
					(
						if a != firstRow.count then
						(
							format "%\n" firstRow[a] to:outlineArrayoutput2
						)
						else
						(	
							format "%" firstRow[a] to:outlineArrayoutput2	
						)
					)
					close outlineArrayoutput2
					free outlineArrayoutput2
					close csvFile
					free csvfile
					clearUndoBuffer()
					gc()
					--c+=2
					--fileExist = doesfileexist outputpath
				)
			)
			rayCreationExport()
			outlineArray()
			delete baseplane
			delete topPlane
			print ("The size was " + (sizeObPlane as string) + " or " + (numofverts as string) + " In verts.")
			end2 = timestamp()
			print ("Duration: " + (((end2 - start)/1000.0)as string) + " seconds.")
			select obj[1]
			--DOSCommand "python C:\\CSVFiles\\conversionArraytoPNG.py"
			gc()
		)
		gc()
	)
	delete cameras
	clearUndoBuffer()
	sizeObPlane += 10
)
delete cameras
gc()
