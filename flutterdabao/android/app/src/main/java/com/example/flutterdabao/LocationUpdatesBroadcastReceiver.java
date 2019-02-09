/*
 * Copyright (C) 2017 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.flutterdabao;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.util.Log;

import com.google.android.gms.location.LocationResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.GeoPoint;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.WriteBatch;
import com.google.type.DayOfWeek;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import static android.content.Context.MODE_PRIVATE;
import static com.example.flutterdabao.LocationRequestHelper.distance;
import static com.example.flutterdabao.LocationRequestHelper.getDouble;
import static com.example.flutterdabao.LocationRequestHelper.putDouble;

/**
 * Receiver for handling location updates.
 *
 * For apps targeting API level O
 * {@link android.app.PendingIntent#getBroadcast(Context, int, Intent, int)} should be used when
 * requesting location updates. Due to limits on background services,
 * {@link android.app.PendingIntent#getService(Context, int, Intent, int)} should not be used.
 *
 *  Note: Apps running on "O" devices (regardless of targetSdkVersion) may receive updates
 *  less frequently than the interval specified in the
 *  {@link com.google.android.gms.location.LocationRequest} when the app is no longer in the
 *  foreground.
 */
public class LocationUpdatesBroadcastReceiver extends BroadcastReceiver {
    private static final String TAG = "LUBroadcastReceiver";

    public static final String ACTION_PROCESS_UPDATES =
            "com.example.flutterdabao.backgroundlocationupdates.action.PROCESS_UPDATES";

    @Override
    public void onReceive(Context context, Intent intent) {

        if (intent != null) {
            final String action = intent.getAction();
            if (ACTION_PROCESS_UPDATES.equals(action)) {
                LocationResult result = LocationResult.extractResult(intent);


                if (result != null) {

                    List<Location> locations = result.getLocations();

                    FirebaseUser currentUser = FirebaseAuth.getInstance().getCurrentUser();

                    if (currentUser != null) {
                        FirebaseFirestore firestore = FirebaseFirestore.getInstance();
                        WriteBatch batch = firestore.batch();
                        SharedPreferences pref = context.getApplicationContext().getSharedPreferences("locations", MODE_PRIVATE);
                        SharedPreferences.Editor editor = pref.edit();

                        for (Location location : locations){

                            double lastLat =  getDouble(pref, "lastLat", 0.0);        // getting Long
                            double lastLong =  getDouble(pref, "lastLong", 0.0);      // getting Long
                            double lastAltitude =  getDouble(pref, "lastAltitude", 0.0);      // getting Long

                            if (lastLat == 0.0 || lastLong == 0.0){
                                setData(location, batch, firestore, currentUser);
                                putDouble(editor, "lastLat", location.getLatitude());
                                putDouble(editor, "lastLong", location.getLongitude());
                                putDouble(editor, "lastAltitude", location.hasAltitude() ? location.getAltitude() : 0.0);
                                editor.commit();


                            } else {

                                Double distance = distance(location.getLatitude(), lastLat, location.getLongitude(), lastLong, location.hasAltitude() ? location.getAltitude(): 0.0,lastAltitude );



                                if (distance > 500) {
                                    Log.d("testing Locations", "onHandleIntent: 2 distance:" + distance.longValue());

                                    setData(location, batch, firestore, currentUser);
                                    putDouble(editor, "lastLat", location.getLatitude());
                                    putDouble(editor, "lastLong", location.getLongitude());
                                    putDouble(editor, "lastAltitude", location.hasAltitude() ? location.getAltitude() : 0.0);
                                    editor.commit();

                                } else {
                                    Log.d("testing Locations", "new location Less than 500 :" + distance );

                                }
                            }

                        }

                        batch.commit();

                    }


                }
            }
        }
    }

    void setData(Location location, WriteBatch batch, FirebaseFirestore firestore, FirebaseUser currentUser) {
        Date locationTime = new Date(location.getTime());
        TimeZone timeZone = TimeZone.getTimeZone("UTC");
        Calendar c = Calendar.getInstance(timeZone);
        c.setTime(locationTime);

        String timeInMilliSeconds = Long.toString(locationTime.getTime());
        int dayOfWeek = c.get(Calendar.DAY_OF_WEEK);
        // this will for example return 3 for tuesday
        dayOfWeek = dayOfWeek - 1;
        if (dayOfWeek == 0) {
            dayOfWeek = 7;
        }

        Date date = new Date();
        String modifiedDate= new SimpleDateFormat("yyyy-MM-dd").format(date);


        DayOfWeek day = DayOfWeek.forNumber(dayOfWeek);

        Map<String,Object> data = new HashMap<String,Object>();
        Map<String,Object> subData = new HashMap<String,Object>();

        subData.put("Location" , new GeoPoint(location.getLatitude(), location.getLongitude()));
        subData.put("Time", locationTime);

        data.put(timeInMilliSeconds , subData);

        batch.set(firestore.collection("locations").document(currentUser.getUid()).collection(day.name()).document(modifiedDate), data,SetOptions.merge());
    }
}
