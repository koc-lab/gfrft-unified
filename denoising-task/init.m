function init(prestring)
    arguments
        prestring (1,1) string = ""
    end

    GSPBOX_PATH = append(prestring, "../gspbox/");
    DATA_PATH   = append(prestring, "../data/tv-graph-datasets/");
    SRC_PATH    = append(prestring, "../src/");
    GFT_PATH    = append(prestring, "../src/gft/");

    addpath(DATA_PATH, GSPBOX_PATH, '-frozen');
    addpath(SRC_PATH, GFT_PATH, '-begin');
    gsp_start;
end
