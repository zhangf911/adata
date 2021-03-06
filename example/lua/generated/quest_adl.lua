local adata_m = require'adata_core'
local ffi = require'ffi'
local ns = require'adata'
local new_buf = adata_m.new_buf;
local resize_buf = adata_m.resize_buf;
local clear_buf = adata_m.clear_buf;
local set_error = adata_m.set_error;
local trace_error = adata_m.trace_error;
local trace_info = adata_m.trace_info;
local get_write_data = adata_m.get_write_data;
local set_read_data = adata_m.set_read_data;
local get_rd_len = adata_m.get_rd_len;
local get_wt_len = adata_m.get_wt_len;
local skip_rd_len = adata_m.skip_rd_len;
local tablen = ns.tablen;

local rd_i32 = adata_m.rd_i32
local rd_u32 = adata_m.rd_u32
local rd_u64 = adata_m.rd_u64
local rd_str = adata_m.rd_str
local skip_rd_i32 = adata_m.skip_rd_i32
local skip_rd_u32 = adata_m.skip_rd_u32
local skip_rd_u64 = adata_m.skip_rd_u64
local skip_rd_str = adata_m.skip_rd_str
local wt_i32 = adata_m.wt_i32
local wt_u32 = adata_m.wt_u32
local wt_u64 = adata_m.wt_u64
local wt_str = adata_m.wt_str
local szof_i32 = adata_m.szof_i32
local szof_u32 = adata_m.szof_u32
local szof_u64 = adata_m.szof_u64
local szof_str = adata_m.szof_str

local field_info = {
  ffi.new("char[11]","description"),
  ffi.new("char[2]","id"),
  ffi.new("char[4]","name"),
}


local mt = {};

local m = {
  quest,
};

m.quest = function()
  local obj = {
    id = 0,
    name = '',
    description = '',
  };
  setmetatable(obj,mt[1]);
  return obj;
end

local mc = {};
mc = {
  adtype = function() return m.quest end,
  skip_read = function(o,buf)
    local offset = get_rd_len(buf);
    local ec,read_tag = rd_u64(buf);
    if ec > 0 then return ec; end;
    local len_tag = 0;
    ec,len_tag = rd_i32(buf);
    if ec > 0 then return ec; end;
    if (read_tag % 2) >= 1 then
      read_tag = read_tag - 1;
      ec = skip_rd_i32(buf);if ec > 0 then trace_error(buf, field_info[2] , -1); return ec; end;
    end
    if (read_tag % 4) >= 2 then
      read_tag = read_tag - 2;
      ec = skip_rd_str(buf,0);if ec > 0 then trace_error(buf, field_info[3] , -1); return ec; end;
    end
    if (read_tag % 8) >= 4 then
      read_tag = read_tag - 4;
      ec = skip_rd_str(buf,0);if ec > 0 then trace_error(buf, field_info[1] , -1); return ec; end;
    end
    if len_tag >= 0 then
      local read_len = get_rd_len(buf) - offset;
      if len_tag > read_len then skip_rd_len(buf, len_tag - read_len); end;
    end
    return ec;
  end,
  size_of = function(o)
    local size = 0
    local tag = 0
    tag = tag + 1;
    if #o.name > 0 then tag = tag + 2; end;
    if #o.description > 0 then tag = tag + 4; end;
    if (tag % 2) >= 1 then
      size = size + szof_i32(o.id);
    end
    if (tag % 4) >= 2 then
      size = size + szof_str(o.name);
    end
    if (tag % 8) >= 4 then
      size = size + szof_str(o.description);
    end
    size = size + szof_u64(tag);
    size = size + szof_i32(size + szof_i32(size));
    return size;
  end,
  read = function(o,buf)
    local offset = get_rd_len(buf);
    local ec,read_tag = rd_u64(buf);
    if ec > 0 then return ec; end;
    local len_tag = 0;
    ec,len_tag = rd_i32(buf);
    if ec > 0 then return ec; end;
    if (read_tag % 2) >= 1 then
      read_tag = read_tag - 1;
      ec,o.id = rd_i32(buf);if ec > 0 then trace_error(buf, field_info[2] , -1); return ec; end;
      if ec > 0 then return ec; end;
    end
    if (read_tag % 4) >= 2 then
      read_tag = read_tag - 2;
      ec,o.name = rd_str(buf,0);if ec > 0 then trace_error(buf, field_info[3] , -1); return ec; end;
      if ec > 0 then return ec; end;
    end
    if (read_tag % 8) >= 4 then
      read_tag = read_tag - 4;
      ec,o.description = rd_str(buf,0);if ec > 0 then trace_error(buf, field_info[1] , -1); return ec; end;
      if ec > 0 then return ec; end;
    end
    if len_tag >= 0 then
      local read_len = get_rd_len(buf) - offset;
      if len_tag > read_len then skip_rd_len(buf, len_tag - read_len); end;
    end
    return ec;
  end,
  write = function(o,buf)
    local write_tag = 0
    write_tag = write_tag + 1;
    if #o.name > 0 then write_tag = write_tag + 2; end;
    if #o.description > 0 then write_tag = write_tag + 4; end;
    ec = wt_u64(buf,write_tag);
    if ec >0 then return ec; end;
    ec = wt_i32(buf,o:size_of());
    if ec >0 then return ec; end;
    if (write_tag % 2) >= 1 then
      ec = wt_i32(buf,o.id);if ec > 0 then trace_error(buf, field_info[2] , -1); return ec; end;
    end
    if (write_tag % 4) >= 2 then
      ec = wt_str(buf,o.name,0);if ec > 0 then trace_error(buf, field_info[3] , -1); return ec; end;
    end
    if (write_tag % 8) >= 4 then
      ec = wt_str(buf,o.description,0);if ec > 0 then trace_error(buf, field_info[1] , -1); return ec; end;
    end
    return ec;
  end,
};
mc.__index = mc;
mt[1] = mc;
if ns.my_game == nil then
  ns.my_game = m;
else
  ns.my_game.quest = m.quest
end
return m;
