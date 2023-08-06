function init(prestring)
    arguments
        prestring (1,1) string = ""
    end

    GSPBOX_PATH = append(prestring, "../gspbox/");
    DATA_PATH   = append(prestring, "../data/tv-graph-datasets/");
    GFT_PATH    = append(prestring, "./gft/");

    addpath(DATA_PATH, GSPBOX_PATH, '-frozen');
    addpath(GFT_PATH, '-begin');
    gsp_start;
end
