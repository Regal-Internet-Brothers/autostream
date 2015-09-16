Strict

Public

' Preprocessor related:
#AUTOSTREAM_IMPLEMENTED = True

' This may be used to toggle calls to ''
#AUTOSTREAM_USE_BUFFERS_DIRECTLY = True
'#AUTOSTREAM_IMPORT_OS = True

' Imports (Public):
Import brl.stream

' Imports (Private):
Private

Import brl.databuffer
Import brl.filestream
Import brl.datastream

#If AUTOSTREAM_IMPORT_OS
	Import os
#Elseif BRL_GAMETARGET_IMPLEMENTED
	Import mojo.app
#End

Public

' Aliases:
#If AUTOSTREAM_IMPORT_OS ' BRL_OS_IMPLEMENTED
	Alias LoadString = os.LoadString
#Elseif BRL_GAMETARGET_IMPLEMENTED
	Alias LoadString = app.LoadString
#End

' Functions:
Function OpenAutoStream:Stream(Path:String, Mode:String="r")
	If (Path.Length() = 0) Then
		Return Null
	Endif
	
	#If TARGET = "html5"
		If (Path.ToLower().Find("monkey://internal") <> -1) Then
			Return Null
		Endif
	#End
	
	#If BRL_FILESTREAM_IMPLEMENTED
		Return FileStream.Open(Path, Mode)
	#Elseif BRL_GAMETARGET_IMPLEMENTED Or BRL_OS_IMPLEMENTED
		Select Mode
			Case "r"
				' Local variable(s):
				Local InputBuffer:DataBuffer = Null
				
				#If AUTOSTREAM_USE_BUFFERS_DIRECTLY
					InputBuffer = DataBuffer.Load(Path)
				#Else
					' Local variable(s):
					Local InputStr:= LoadString(Path)
					
					If (InputStr.Length() = 0) Then
						Return Null
					Endif
					
					InputBuffer = New DataBuffer(InputStr.Length())
					InputBuffer.PokeString(InputStr)
				#End
				
				If (InputBuffer = Null) Then
					Return Null
				Endif
				
				Return New DataStream(InputBuffer)
		End Select
	#Else
		#Error("Unable to find a suitable stream-type.")
	#End
	
	' Return the default response.
	Return Null
End

Function CloseAutoStream:Bool(S:Stream, StreamIsCustom:Bool=False)
	' Check for errors:
	If (S = Null) Then
		Return False
	Endif
	
	' Close the stream specified:
	If (Not StreamIsCustom) Then
		S.Close()
	Endif
	
	' Return the default response.
	Return True
End