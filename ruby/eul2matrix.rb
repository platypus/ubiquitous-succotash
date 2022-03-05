##eul2matrix.rb

require 'matrix'

def eul2mat (ang)
	angle = ang.map { |i| (i.to_f/180)*Math::PI }
	z1mat = Matrix.rows([[Math.cos(angle[0]),-Math.sin(angle[0]),0],[Math.sin(angle[0]),Math.cos(angle[0]),0],[0,0,1]]) 
	xmat = Matrix.rows([[1,0,0],[0,Math.cos(angle[1]),-Math.sin(angle[1])],[0,Math.sin(angle[1]),Math.cos(angle[1])]])
	z2mat = Matrix.rows([[Math.cos(angle[2]),-Math.sin(angle[2]),0],[Math.sin(angle[2]),Math.cos(angle[2]),0],[0,0,1]]) 
	rotmat = z1mat*xmat*z2mat
	#theta = Math.acos((Matrix.trace(rotmat)-1)/2)
	#multi = 1/(2*sin(theta))
	return rotmat
end

def eul2trans (ang)
	angle = ang.map { |i| (i.to_f/180)*Math::PI }
	z1mat = Matrix.rows([[Math.cos(angle[0]),-Math.sin(angle[0]),0],[Math.sin(angle[0]),Math.cos(angle[0]),0],[0,0,1]]) 
	xmat = Matrix.rows([[1,0,0],[0,Math.cos(angle[1]),-Math.sin(angle[1])],[0,Math.sin(angle[1]),Math.cos(angle[1])]])
	z2mat = Matrix.rows([[Math.cos(angle[2]),-Math.sin(angle[2]),0],[Math.sin(angle[2]),Math.cos(angle[2]),0],[0,0,1]]) 
	rotmat = z1mat*xmat*z2mat
	#theta = Math.acos((Matrix.trace(rotmat)-1)/2)
	#multi = 1/(2*sin(theta))
	transmat = rotmat.transpose()
	return transmat
end




angone = [0,0,0]
angtwo = [0,90,0]

p = eul2mat(angone)
q = eul2trans(angtwo)

r = p*q
theta = Math.acos((r.trace()-1)/2)
thetad = (180/Math::PI)*theta
puts thetad
