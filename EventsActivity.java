package com.lastdojodev.codebluepro;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListView;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

import uk.co.chrisjenx.calligraphy.CalligraphyConfig;

public class EventsActivity extends AppCompatActivity
{
    ArrayList<String> eventArrayList = new ArrayList<>();
    private ArrayAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_events);

        CalligraphyConfig.initDefault(new CalligraphyConfig.Builder()
                        .setDefaultFontPath("fonts/HelveticaNeue-UltraLight.ttf")
                        .setFontAttrId(R.attr.fontPath)
                        .build()
        );

        Toolbar eventToolbar = findViewById(R.id.eventToolbar);
        if (eventToolbar != null)
        {
                setSupportActionBar(eventToolbar);
                getDelegate().getSupportActionBar().setTitle(R.string.eventListTitle);
                getDelegate().getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        final ListView listview = findViewById(R.id.eventsListView);

        String[] initialEventValues = new String[]
                {
                        "AED pads applied",
                        "Backboard",
                        "Bag-mask device",
                        "Cardiac Monitor",
                        "Endotracheal intubation",
                        "IO access",
                        "IV access",
                        "Nasal cannula",
                        "Nasopharyngeal airway",
                        "Oropharyngeal airway",
                        "Oxygen",
                        "Pulse check",
                        "Supraglottic airway",
                        "Waveform capnography"
                };

        // Sort array list
        Arrays.sort(initialEventValues, String.CASE_INSENSITIVE_ORDER);

        //Initialize items only once
        SharedPreferences eventPrefs = getSharedPreferences("firstRun", 0);
        if (!eventPrefs.getBoolean("eventListInitialized", false))
        {
            Collections.addAll(eventArrayList, initialEventValues);

            SharedPreferences.Editor edit = eventPrefs.edit();
            edit.putBoolean("eventListInitialized", true);
            edit.commit();

            saveArrayList();

            Log.d("myTag", "Inside preferences");
        }

        getArrayList();

        adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, eventArrayList);

        listview.setAdapter(adapter);

        //Swipe to delete
        SwipeListViewTouchListener touchListener = new SwipeListViewTouchListener(listview, new SwipeListViewTouchListener.OnSwipeCallback()
        {
            @Override
            public void onSwipeLeft(ListView listView, int [] reverseSortedPositions)
            {
                if(listView != null && reverseSortedPositions != null) {
                    showDeleteAlertDialog(listView, reverseSortedPositions);
                }
            }
            @Override
            public void onSwipeRight(ListView listView, int [] reverseSortedPositions)
            {
                if(listView != null && reverseSortedPositions != null) {
                    showDeleteAlertDialog(listView, reverseSortedPositions);
                }
            }
        },true, false);


        listview.setOnTouchListener(touchListener);
        listview.setOnScrollListener(touchListener.makeScrollListener());

        listview.setOnItemClickListener(new AdapterView.OnItemClickListener()
        {
            @Override
            public void onItemClick(AdapterView<?> parent, final View view, int position, long id)
            {
                final String item = (String) parent.getItemAtPosition(position);
                sendResultToParent(item);
                adapter.notifyDataSetChanged();
                saveArrayList();
                finish();
            }
        });

        //Initialize FAB OnClick
        findViewById(R.id.eventFabButton).setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                addItemToList();
                Log.d("myTag", "fabonClick");
            }
        });
    }

    /*@Override
    protected void attachBaseContext(Context newBase)
    {
        super.attachBaseContext(CalligraphyContextWrapper.wrap(newBase));
    }*/

    public void saveArrayList()
    {
        //Saves ArrayList
        setStringArrayPref(this, "eventsList", eventArrayList);
        Log.d("myTag", "saveArrayList");
    }

    public void getArrayList()
    {
        //Get ArrayList
        eventArrayList = getStringArrayPref(this, "eventsList");
    }

    public void sendResultToParent(String selectedEvent)
    {
        //Put string data in new intent for parent
        Intent data = new Intent();
        data.putExtra("eventSelection", selectedEvent);
        setResult(RESULT_OK, data);
    }

    public void addItemToList()
    {
        AlertDialog.Builder alert = new AlertDialog.Builder(this);

        alert.setTitle("New Item");
        alert.setMessage("Enter new item.");

        // Set an EditText view to get user input
        final EditText input = new EditText(this);
        alert.setView(input);

        alert.setPositiveButton("Ok", new DialogInterface.OnClickListener()
        {
            public void onClick(DialogInterface dialog, int whichButton)
            {
                String inputValue = input.getText().toString();
                try
                {
                    Log.d("myTag", inputValue);
                    Integer position = eventArrayList.size() - 1;
                    Log.d("myTag", String.valueOf(position));
                    eventArrayList.add(position, inputValue);
                    Log.d("myTag", "completed ok");
                    Collections.sort(eventArrayList, String.CASE_INSENSITIVE_ORDER);
                    adapter.notifyDataSetChanged();
                    saveArrayList();
                }
                catch (Exception e)
                {
                    e.printStackTrace();
                }
            }
        });

        alert.setNegativeButton("Cancel", new DialogInterface.OnClickListener()
        {
            public void onClick(DialogInterface dialog, int whichButton)
            {
                // Canceled.
            }
        });

        alert.show();
    }

    public static void setStringArrayPref(Context context, String key, ArrayList<String> values)
    {
        Log.d("myTag", "Saving");
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = prefs.edit();
        JSONArray a = new JSONArray();
        for (int i = 0; i < values.size(); i++)
        {
            a.put(values.get(i));
        }
        if (!values.isEmpty())
        {
            editor.putString(key, a.toString());
        } else
        {
            editor.putString(key, null);
        }
        editor.commit();
    }

    public static ArrayList<String> getStringArrayPref(Context context, String key)
    {
        Log.d("myTag", "Getting data");
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        String json = prefs.getString(key, null);
        ArrayList<String> itemList = new ArrayList<>();
        if (json != null)
        {
            try
            {
                JSONArray a = new JSONArray(json);
                for (int i = 0; i < a.length(); i++)
                {
                    String item = a.optString(i);
                    itemList.add(item);
                }
            }
            catch (JSONException e)
            {
                e.printStackTrace();
            }
        }
        return itemList;
    }

    //Swipe confirmation
    public void showDeleteAlertDialog(final ListView listView, final int [] reverseSortedPositions)
    {
        String selectedFromList = (String) listView.getItemAtPosition(reverseSortedPositions[0]);

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Delete Item Entry");
        builder.setMessage("Do you want to delete this item: " + selectedFromList + "?");
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                Log.d("TAG", "onClick showAlertDialog: Canceled pressed.");
            }
        });
        builder.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                Log.d("TAG", "setpositivebutton - delete item");

                //Get item string
                String selectedFromList = (String) listView.getItemAtPosition(reverseSortedPositions[0]);

                //Delete log entry from list
                eventArrayList.remove(reverseSortedPositions[0]);
                Log.d("TAG", "List after removing item: " + eventArrayList);
                saveArrayList();
                adapter.notifyDataSetChanged();
            }
        });
        builder.show();
    }

    public boolean onSupportNavigateUp()
    {
        onBackPressed();
        return true;
    }

}
