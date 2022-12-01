function disp(obj)
try display(obj.params)
catch msg
    disp(obj);
end
end