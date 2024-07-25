function [id] = genUUID
%GENUUID Outputs a character array with a completely unique identifier
%   Uses java.util.UUID.randomUUID method.


temp = java.util.UUID.randomUUID;
myuuid = temp.toString;
id = char(myuuid);
% fprintf('%s\n', char(myuuid))


end

