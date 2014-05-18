Strict

Public

' Preprocessor related:
#AUTOSTREAM_USE_BUFFERS_DIRECTLY = True

' Imports:
Import brl.stream

Private

Import brl

#If TARGET = "glfw" Or TARGET = "stdcpp" Or TARGET = "sexy"
	Import os
#End

#If (BRL_OS_IMPLEMENTED Or BRL_GAMETARGET_IMPLEMENTED)
	Import publicdatastream
#End

#If Not BRL_OS_IMPLEMENTED And BRL_GAMETARGET_IMPLEMENTED
	Import mojo.app
#End

Public

#Rem
Import brl.databuffer
Import brl.stream

Import brl.filestream
Import brl.datastream
#End

' Aliases:
#If BRL_OS_IMPLEMENTED
	Alias LoadString = os.LoadString
#Elseif BRL_GAMETARGET_IMPLEMENTED
	Alias LoadString = app.LoadString
#End

' Functions:
Function OpenAutoStream:Stream(Path:String, Mode:String="r")
	' Local variable(s):
	Local S:Stream = Null
	
	If (Path.Length() = 0) Then Return Null
	
	#If TARGET = "html5"
		If (Path.ToLower().Find("monkey://internal") <> -1) Then
			Return Null
		Endif
	#End
	
	#If BRL_FILESTREAM_IMPLEMENTED
		S = FileStream.Open(Path, Mode)
	#Elseif BRL_GAMETARGET_IMPLEMENTED Or BRL_OS_IMPLEMENTED
		Select Mode
			Case "r"
				' Local variable(s):
				Local InputBuffer:DataBuffer = Null
				
				#If AUTOSTREAM_USE_BUFFERS_DIRECTLY
					InputBuffer = DataBuffer.Load(Path)
				#Else
					' Local variable(s):
					Local InputStr:String = LoadString(Path)
					
					If (InputStr.Length() = 0) Then Return Null
					
					InputBuffer = New DataBuffer(InputStr.Length())
					InputBuffer.PokeString(InputStr)
				#End
				
				If (InputBuffer = Null) Then
					Return Null
				Endif
				
				S = New DataStream(InputBuffer)
			Default
				#If BRL_OS_IMPLEMENTED
					If (Path.Length()) Then
						S = New PublicDataStream(True, Path)
					Endif
				#Else
					#If CONFIG = "debug"
						Error("Writing files is disabled on this target.")
					#End
				#End
		End Select
	#Else
		#AUTOSTREAM_IMPLEMENTED = False
		
		'#Error("Unable to find a suitable stream-type.")
	#End
	
	Return S
End

Function CloseAutoStream:Bool(S:Stream, StreamIsCustom:Bool=False)
	If (S = Null) Then Return False
	
	#If Not BRL_FILESTREAM_IMPLEMENTED And (BRL_OS_IMPLEMENTED Or BRL_GAMETARGET_IMPLEMENTED)
		' Local variable(s):
		Local DS:= PublicDataStream(S)
		
		If (DS <> Null) Then
			If (DS.ShouldResize) Then
				#If BRL_OS_IMPLEMENTED
					If (DS.Path.Length()) Then
						SaveString(DS.Buffer.PeekString(0), DS.Path)
					Endif
				#End
			Endif
		Endif
	#End
	
	' Close the stream specified.
	If (Not StreamIsCustom) Then S.Close()
	
	' Return the default response.
	Return True
End

' Preprocessor related:

' Set the implementation flag to true.
#AUTOSTREAM_IMPLEMENTED = True