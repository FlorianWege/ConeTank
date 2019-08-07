function ret = Stufen( PID )
    global stufe0factor stufe1factor stufe2factor stufe3factor hysterese out_letzt delay;
    
    if (PID > stufe2factor)
        out = stufe3factor;
    else
        if (PID > stufe1factor)
            out = stufe2factor;
        else
            if (PID > stufe0factor)
                out = stufe1factor;
            else
                out = 0;
            end
        end
    end

    if (out_letzt == -1 || (abs(out_letzt - out) >= hysterese && delay > 10))
        delay = 0;
        out_letzt = out;
    end
    
    delay = delay + 1;

    ret = out_letzt;
end

